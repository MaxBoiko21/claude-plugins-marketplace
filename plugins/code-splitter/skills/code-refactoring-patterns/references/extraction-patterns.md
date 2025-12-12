# Detailed Extraction Patterns

## PHP / Laravel Extraction Patterns

### Controller Extraction Pattern

**Before:**
```php
class UserController extends Controller {
    public function store(Request $request) {
        // Validation (10 lines)
        if (!$request->input('email')) {
            return response()->json(['error' => 'Email required'], 422);
        }
        if (User::where('email', $request->input('email'))->exists()) {
            return response()->json(['error' => 'Email exists'], 422);
        }

        // Business logic (20 lines)
        $user = new User();
        $user->email = $request->input('email');
        $user->password = Hash::make($request->input('password'));
        $user->name = $request->input('name');
        $user->save();

        // Send notifications (5 lines)
        Mail::send('emails.welcome', ['user' => $user], function($msg) use ($user) {
            $msg->to($user->email)->subject('Welcome!');
        });

        // Return response
        return response()->json(['user' => $user], 201);
    }
}
```

**After: Extract to Action**
```php
class UserController extends Controller {
    public function store(CreateUserRequest $request, CreateUserAction $action) {
        $user = $action->handle($request->validated());
        return response()->json(['user' => $user], 201);
    }
}
```

```php
// app/Actions/Users/CreateUserAction.php
final readonly class CreateUserAction {
    public function __construct(private Mail $mail) {}

    public function handle(array $data): User {
        $user = User::create([
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'name' => $data['name'],
        ]);

        $this->mail->send('emails.welcome', ['user' => $user], function($msg) use ($user) {
            $msg->to($user->email)->subject('Welcome!');
        });

        return $user;
    }
}
```

**Validation in Form Request:**
```php
class CreateUserRequest extends FormRequest {
    public function rules(): array {
        return [
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
            'name' => 'required|string|max:255',
        ];
    }
}
```

### Model Extraction Pattern

**Before:**
```php
class Order extends Model {
    public function __construct() {
        // 50+ lines of methods
        // Creating, updating, validating, calculating, shipping, refunding...
    }
}
```

**After: Extract Concerns to Traits and Relations**
```php
class Order extends Model {
    use HasStatus, HasTimestamps, Billable;

    public function items(): HasMany {
        return $this->hasMany(OrderItem::class);
    }

    public function customer(): BelongsTo {
        return $this->belongsTo(Customer::class);
    }
}
```

Extract specific operations to Actions:
- `CreateOrderAction` - Order creation
- `ShipOrderAction` - Shipping logic
- `RefundOrderAction` - Refund logic
- `CalculateOrderTotalAction` - Calculation logic

### Query Scope Pattern

**Before:**
```php
class User extends Model {
    public function getActiveUsers() {
        return User::where('is_active', true)
            ->where('deleted_at', null)
            ->orderBy('created_at', 'desc')
            ->get();
    }
}

// Usage: Scattered throughout codebase
$users = User::where('is_active', true)->where('deleted_at', null)->get();
```

**After: Extract to Scopes**
```php
class User extends Model {
    public function scopeActive($query) {
        return $query->where('is_active', true);
    }

    public function scopeNotDeleted($query) {
        return $query->whereNull('deleted_at');
    }
}

// Usage: Consistent, reusable
$users = User::active()->notDeleted()->latest()->get();
```

## React Extraction Patterns

### Complex Component Extraction

**Before:**
```jsx
export function UserDashboard({ userId }) {
    const [user, setUser] = useState(null);
    const [posts, setPosts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [formData, setFormData] = useState({});
    const [errors, setErrors] = useState({});

    useEffect(() => {
        // Fetch user
        fetch(`/api/users/${userId}`)
            .then(r => r.json())
            .then(data => setUser(data));

        // Fetch posts
        fetch(`/api/users/${userId}/posts`)
            .then(r => r.json())
            .then(data => setPosts(data));

        setLoading(false);
    }, [userId]);

    const handleSubmit = (e) => {
        e.preventDefault();
        // Validate form
        // Update user
        // Handle errors
    };

    if (loading) return <div>Loading...</div>;

    return (
        <div>
            <div>{user?.name}</div>
            <form onSubmit={handleSubmit}>
                {/* 50 lines of form fields */}
            </form>
            <div>
                {posts.map(post => (
                    <div key={post.id}>{post.title}</div>
                ))}
            </div>
        </div>
    );
}
```

**After: Extract Hooks and Components**

```jsx
// Custom hooks
export function useUserData(userId) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetch(`/api/users/${userId}`)
            .then(r => r.json())
            .then(data => setUser(data))
            .finally(() => setLoading(false));
    }, [userId]);

    return { user, loading };
}

export function useUserForm(initialUser) {
    const [formData, setFormData] = useState(initialUser || {});
    const [errors, setErrors] = useState({});

    const validate = () => { /* validation logic */ };
    const submit = async () => { /* submit logic */ };

    return { formData, setFormData, errors, validate, submit };
}

// Extracted components
function UserProfile({ user }) {
    return <div>{user?.name}</div>;
}

function UserEditForm({ user, onSubmit }) {
    const form = useUserForm(user);
    return (
        <form onSubmit={form.submit}>
            {/* 50 lines now focused on rendering */}
        </form>
    );
}

function UserPosts({ userId }) {
    const [posts, setPosts] = useState([]);

    useEffect(() => {
        fetch(`/api/users/${userId}/posts`)
            .then(r => r.json())
            .then(setPosts);
    }, [userId]);

    return posts.map(post => <PostCard key={post.id} post={post} />);
}

// Clean main component
export function UserDashboard({ userId }) {
    const { user, loading } = useUserData(userId);

    if (loading) return <div>Loading...</div>;

    return (
        <div>
            <UserProfile user={user} />
            <UserEditForm user={user} />
            <UserPosts userId={userId} />
        </div>
    );
}
```

### Hook Extraction Pattern

**Before:**
```jsx
function LoginForm() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [errors, setErrors] = useState({});
    const [isSubmitting, setIsSubmitting] = useState(false);

    const validateEmail = (value) => {
        if (!value.includes('@')) {
            return 'Invalid email';
        }
        return '';
    };

    const validatePassword = (value) => {
        if (value.length < 8) {
            return 'Password too short';
        }
        return '';
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsSubmitting(true);

        const emailError = validateEmail(email);
        const passwordError = validatePassword(password);

        if (emailError || passwordError) {
            setErrors({ email: emailError, password: passwordError });
            setIsSubmitting(false);
            return;
        }

        try {
            const response = await fetch('/api/login', {
                method: 'POST',
                body: JSON.stringify({ email, password })
            });
            // Handle response
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            {/* Form JSX */}
        </form>
    );
}
```

**After: Extract Custom Hook**

```jsx
function useLoginForm() {
    const [formData, setFormData] = useState({ email: '', password: '' });
    const [errors, setErrors] = useState({});
    const [isSubmitting, setIsSubmitting] = useState(false);

    const validators = {
        email: (value) => !value.includes('@') ? 'Invalid email' : '',
        password: (value) => value.length < 8 ? 'Password too short' : '',
    };

    const validate = () => {
        const newErrors = {};
        for (const [field, validator] of Object.entries(validators)) {
            const error = validator(formData[field]);
            if (error) newErrors[field] = error;
        }
        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const submit = async (onSuccess) => {
        if (!validate()) return;

        setIsSubmitting(true);
        try {
            const response = await fetch('/api/login', {
                method: 'POST',
                body: JSON.stringify(formData)
            });
            onSuccess(response);
        } finally {
            setIsSubmitting(false);
        }
    };

    return { formData, setFormData, errors, isSubmitting, submit };
}

function LoginForm() {
    const form = useLoginForm();

    return (
        <form onSubmit={(e) => {
            e.preventDefault();
            form.submit();
        }}>
            <input
                value={form.formData.email}
                onChange={(e) => form.setFormData({...form.formData, email: e.target.value})}
            />
            {form.errors.email && <span>{form.errors.email}</span>}

            <input
                type="password"
                value={form.formData.password}
                onChange={(e) => form.setFormData({...form.formData, password: e.target.value})}
            />
            {form.errors.password && <span>{form.errors.password}</span>}

            <button type="submit" disabled={form.isSubmitting}>
                Login
            </button>
        </form>
    );
}
```

## Node.js / TypeScript Extraction Patterns

### Service Extraction Pattern

**Before:**
```typescript
class UserManager {
    async createUser(data) { /* 30 lines */ }
    async updateUser(id, data) { /* 20 lines */ }
    async deleteUser(id) { /* 15 lines */ }
    async sendWelcomeEmail(userId) { /* 10 lines */ }
    async sendPasswordReset(userId) { /* 10 lines */ }
    async checkPermissions(userId, action) { /* 15 lines */ }
    async assignRole(userId, roleId) { /* 10 lines */ }
    async removeRole(userId, roleId) { /* 10 lines */ }
}
```

**After: Extract to Focused Services**

```typescript
class UserService {
    async create(data: UserData): Promise<User> { /* creation */ }
    async update(id: string, data: UserData): Promise<User> { /* update */ }
    async delete(id: string): Promise<void> { /* delete */ }
}

class UserEmailService {
    async sendWelcome(userId: string): Promise<void> { /* welcome email */ }
    async sendPasswordReset(userId: string): Promise<void> { /* reset email */ }
}

class UserPermissionService {
    async checkPermission(userId: string, action: string): Promise<boolean> { /* check */ }
    async assignRole(userId: string, roleId: string): Promise<void> { /* assign */ }
    async removeRole(userId: string, roleId: string): Promise<void> { /* remove */ }
}
```

### Helper Function Extraction

**Before:**
```typescript
async function processOrder(orderId: string) {
    // Fetch order (5 lines)
    const order = await Order.findById(orderId);
    if (!order) throw new Error('Order not found');

    // Validate items (8 lines)
    for (const item of order.items) {
        if (item.quantity <= 0) throw new Error('Invalid quantity');
        if (!item.productId) throw new Error('Missing product');
    }

    // Calculate totals (6 lines)
    let subtotal = 0;
    let tax = 0;
    for (const item of order.items) {
        subtotal += item.price * item.quantity;
    }
    tax = subtotal * 0.1;

    // Update order (3 lines)
    order.subtotal = subtotal;
    order.tax = tax;
    order.total = subtotal + tax;
    await order.save();
}
```

**After: Extract Helper Functions**

```typescript
function validateOrderItems(items: OrderItem[]): void {
    for (const item of items) {
        if (item.quantity <= 0) throw new Error('Invalid quantity');
        if (!item.productId) throw new Error('Missing product');
    }
}

function calculateOrderTotals(items: OrderItem[]): { subtotal: number; tax: number; total: number } {
    const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const tax = subtotal * 0.1;
    return { subtotal, tax, total: subtotal + tax };
}

async function processOrder(orderId: string) {
    const order = await Order.findById(orderId);
    if (!order) throw new Error('Order not found');

    validateOrderItems(order.items);

    const totals = calculateOrderTotals(order.items);
    Object.assign(order, totals);
    await order.save();
}
```

## General Principles

### Group Related Operations

Keep code that changes together:
- Validation logic stays together
- Business logic stays together
- Response formatting stays together
- Error handling stays together

### Extract Early

Don't wait for duplication:
- If you understand how to extract → Extract immediately
- Premature extraction is better than tangled code
- Single-use utilities are still valid if they're complex

### Name for Intent

Names should explain purpose:
- `validateUserEmail()` not `checkEmail()`
- `calculateOrderTotal()` not `math()`
- `fetchUserWithPosts()` not `getUser()`

### Keep Dependencies Clear

Extracted code should:
- Declare all dependencies explicitly (parameters, constructor injection)
- Not rely on global state or side effects
- Be testable in isolation
