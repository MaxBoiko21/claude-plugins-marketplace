# Framework-Specific Action Patterns

## Laravel Action Pattern - Complete Guide

### Creating Action Classes

**Directory convention:**
```
app/Actions/
├── Users/
│   ├── CreateUserAction.php
│   ├── UpdateUserAction.php
│   ├── DeleteUserAction.php
│   └── SendUserInviteAction.php
├── Orders/
│   ├── CreateOrderAction.php
│   ├── ProcessPaymentAction.php
│   └── ShipOrderAction.php
└── Notifications/
    ├── SendWelcomeEmailAction.php
    └── SendPasswordResetAction.php
```

### Complete Action Example

```php
<?php

declare(strict_types=1);

namespace App\Actions\Users;

use App\Models\User;
use App\Notifications\UserCreatedNotification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Notification;

final readonly class CreateUserAction {
    public function __construct(
        private UserRepository $users,
        private EventBus $events,
    ) {}

    public function handle(CreateUserDTO $data): User {
        return DB::transaction(function () use ($data) {
            // 1. Validate (can also use Form Request)
            $this->validate($data);

            // 2. Create user
            $user = $this->users->create([
                'name' => $data->name,
                'email' => $data->email,
                'password' => Hash::make($data->password),
            ]);

            // 3. Side effects / notifications
            Notification::send($user, new UserCreatedNotification($user));

            // 4. Dispatch event for other listeners
            $this->events->dispatch(new UserCreated($user));

            return $user;
        });
    }

    private function validate(CreateUserDTO $data): void {
        if (User::where('email', $data->email)->exists()) {
            throw new UserAlreadyExistsException();
        }
    }
}
```

### Using Actions in Controllers

```php
class UserController extends Controller {
    public function store(
        CreateUserRequest $request,
        CreateUserAction $createUser,
    ) {
        try {
            $user = $createUser->handle(
                CreateUserDTO::from($request->validated())
            );

            return response()->json(['user' => new UserResource($user)], 201);
        } catch (UserAlreadyExistsException) {
            return response()->json(['error' => 'User already exists'], 422);
        }
    }
}
```

### Using Actions in Jobs

```php
class SendBulkInvitesJob implements ShouldQueue {
    public function __construct(private array $emails) {}

    public function handle(SendUserInviteAction $sendInvite) {
        foreach ($this->emails as $email) {
            $sendInvite->handle($email);
        }
    }
}
```

### Creating Related Action Classes

```php
// app/Actions/Orders/CreateOrderAction.php
final readonly class CreateOrderAction {
    public function __construct(
        private OrderRepository $orders,
        private ProcessPaymentAction $processPayment,
        private SendConfirmationEmailAction $sendEmail,
    ) {}

    public function handle(CreateOrderDTO $data): Order {
        return DB::transaction(function () use ($data) {
            // Create order
            $order = $this->orders->create($data->toArray());

            // Process payment
            try {
                $this->processPayment->handle($order, $data->paymentInfo);
            } catch (PaymentFailedException $e) {
                $order->markFailed();
                throw $e;
            }

            // Send confirmation
            $this->sendEmail->handle($order);

            return $order;
        });
    }
}
```

### Testing Actions

```php
class CreateUserActionTest extends TestCase {
    public function test_creates_user_with_valid_data() {
        $action = new CreateUserAction(
            new UserRepository(),
            new EventBus(),
        );

        $user = $action->handle(new CreateUserDTO(
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
        ));

        expect($user)->toBeInstanceOf(User::class);
        expect($user->email)->toBe('john@example.com');
    }
}
```

## React Component & Hook Pattern

### Complete Component Example

```tsx
// src/components/UserForm/UserForm.tsx
import { useState } from 'react';
import { useForm } from './useUserForm';
import { FormField } from '../FormField';
import { Button } from '../Button';

interface UserFormProps {
    initialUser?: User;
    onSuccess?: (user: User) => void;
}

export function UserForm({ initialUser, onSuccess }: UserFormProps) {
    const form = useForm(initialUser);
    const [isLoading, setIsLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!form.validate()) {
            return;
        }

        setIsLoading(true);
        try {
            const user = await form.submit();
            onSuccess?.(user);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <form onSubmit={handleSubmit} className="space-y-4">
            <FormField
                label="Name"
                value={form.data.name}
                onChange={(value) => form.setField('name', value)}
                error={form.errors.name}
            />

            <FormField
                label="Email"
                type="email"
                value={form.data.email}
                onChange={(value) => form.setField('email', value)}
                error={form.errors.email}
            />

            <Button
                type="submit"
                label={initialUser ? 'Update' : 'Create'}
                disabled={isLoading}
            />
        </form>
    );
}
```

### Custom Hook Example

```tsx
// src/components/UserForm/useUserForm.ts
import { useState } from 'react';
import { usersApi } from '@/services/api/users';

interface FormData {
    name: string;
    email: string;
}

interface FormErrors {
    name?: string;
    email?: string;
}

export function useForm(initialUser?: User) {
    const [data, setData] = useState<FormData>(
        initialUser ? { name: initialUser.name, email: initialUser.email } : {
            name: '',
            email: '',
        }
    );
    const [errors, setErrors] = useState<FormErrors>({});

    const setField = (field: keyof FormData, value: string) => {
        setData((prev) => ({ ...prev, [field]: value }));
        // Clear error when user starts typing
        if (errors[field]) {
            setErrors((prev) => ({ ...prev, [field]: undefined }));
        }
    };

    const validate = (): boolean => {
        const newErrors: FormErrors = {};

        if (!data.name.trim()) {
            newErrors.name = 'Name is required';
        }

        if (!data.email.includes('@')) {
            newErrors.email = 'Valid email required';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const submit = async (): Promise<User> => {
        if (initialUser) {
            return await usersApi.update(initialUser.id, data);
        } else {
            return await usersApi.create(data);
        }
    };

    return { data, setData, setField, errors, validate, submit };
}
```

### Component Composition Example

```tsx
// src/sections/UserDashboard.tsx
import { useUser } from '@/hooks/api/useUser';
import { UserProfile } from './UserProfile';
import { UserStats } from './UserStats';
import { UserActivity } from './UserActivity';

interface UserDashboardProps {
    userId: string;
}

export function UserDashboard({ userId }: UserDashboardProps) {
    const { user, isLoading } = useUser(userId);

    if (isLoading) return <div>Loading...</div>;
    if (!user) return <div>User not found</div>;

    return (
        <div className="space-y-6">
            <UserProfile user={user} />
            <UserStats user={user} />
            <UserActivity userId={userId} />
        </div>
    );
}
```

### Extracted Child Components

```tsx
// src/sections/UserProfile.tsx
export function UserProfile({ user }: { user: User }) {
    return (
        <div className="card">
            <h2>{user.name}</h2>
            <p>{user.email}</p>
        </div>
    );
}

// src/sections/UserStats.tsx
export function UserStats({ user }: { user: User }) {
    return (
        <div className="grid grid-cols-3 gap-4">
            <StatCard label="Orders" value={user.orderCount} />
            <StatCard label="Spent" value={`$${user.totalSpent}`} />
            <StatCard label="Member Since" value={user.createdAt} />
        </div>
    );
}

// src/sections/UserActivity.tsx
export function UserActivity({ userId }: { userId: string }) {
    const { activities, isLoading } = useUserActivities(userId);

    return (
        <div className="card">
            <h3>Recent Activity</h3>
            {activities?.map((activity) => (
                <ActivityItem key={activity.id} activity={activity} />
            ))}
        </div>
    );
}
```

## Vue Composable Pattern

### Complete Composable Example

```typescript
// src/composables/useUserForm.ts
import { ref, computed, reactive } from 'vue';
import { usersApi } from '@/services/api/users';

interface FormData {
    name: string;
    email: string;
}

interface FormErrors {
    name?: string;
    email?: string;
}

export function useUserForm(initialUser: User | null = null) {
    const data = reactive<FormData>(
        initialUser ? { name: initialUser.name, email: initialUser.email } : {
            name: '',
            email: '',
        }
    );

    const errors = reactive<FormErrors>({});
    const isSubmitting = ref(false);

    const validate = (): boolean => {
        errors.name = undefined;
        errors.email = undefined;

        if (!data.name.trim()) {
            errors.name = 'Name is required';
        }

        if (!data.email.includes('@')) {
            errors.email = 'Valid email required';
        }

        return Object.keys(errors).length === 0;
    };

    const submit = async (): Promise<User> => {
        if (!validate()) {
            throw new Error('Validation failed');
        }

        isSubmitting.value = true;
        try {
            if (initialUser) {
                return await usersApi.update(initialUser.id, data);
            } else {
                return await usersApi.create(data);
            }
        } finally {
            isSubmitting.value = false;
        }
    };

    const setField = (field: keyof FormData, value: string) => {
        data[field] = value;
        if (errors[field]) {
            errors[field] = undefined;
        }
    };

    return {
        data,
        errors,
        isSubmitting: computed(() => isSubmitting.value),
        validate,
        submit,
        setField,
    };
}
```

### Vue Component Using Composable

```vue
<template>
    <form @submit.prevent="handleSubmit" class="space-y-4">
        <FormField
            label="Name"
            v-model="form.data.name"
            :error="form.errors.name"
        />

        <FormField
            label="Email"
            type="email"
            v-model="form.data.email"
            :error="form.errors.email"
        />

        <Button
            type="submit"
            :label="initialUser ? 'Update' : 'Create'"
            :disabled="form.isSubmitting"
        />
    </form>
</template>

<script setup lang="ts">
import { useUserForm } from '@/composables/useUserForm';
import { defineProps, defineEmits } from 'vue';

const props = defineProps<{ initialUser?: User }>();
const emit = defineEmits<{ success: [user: User] }>();

const form = useUserForm(props.initialUser);

const handleSubmit = async () => {
    try {
        const user = await form.submit();
        emit('success', user);
    } catch (error) {
        console.error('Form submission failed', error);
    }
};
</script>
```

## Node.js / TypeScript Pattern

### Service + Action Example

```typescript
// src/services/OrderService.ts
export class OrderService {
    constructor(
        private db: Database,
        private paymentGateway: PaymentGateway,
    ) {}

    async create(data: CreateOrderDTO): Promise<Order> {
        const order = await this.db.orders.create({
            customerId: data.customerId,
            items: data.items,
            total: this.calculateTotal(data.items),
        });

        return order;
    }

    async update(id: string, data: UpdateOrderDTO): Promise<Order> {
        const order = await this.db.orders.update(id, data);
        return order;
    }

    private calculateTotal(items: OrderItem[]): number {
        return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    }
}

// src/actions/CreateOrderAction.ts
export class CreateOrderAction {
    constructor(
        private orderService: OrderService,
        private paymentService: PaymentService,
        private emailService: EmailService,
    ) {}

    async execute(data: CreateOrderDTO): Promise<Order> {
        // Create order
        const order = await this.orderService.create(data);

        // Process payment
        try {
            const payment = await this.paymentService.process(
                order.id,
                order.total,
                data.paymentMethod
            );

            // Mark order as paid
            await this.orderService.markPaid(order.id, payment.transactionId);
        } catch (error) {
            // Payment failed, mark order as failed
            await this.orderService.markFailed(order.id);
            throw new PaymentFailedException('Payment processing failed');
        }

        // Send confirmation email
        await this.emailService.sendOrderConfirmation(order);

        return order;
    }
}
```

### Using Actions in Handlers

```typescript
// src/routes/orders.ts
import express from 'express';

const router = express.Router();

router.post('/orders', async (req, res, next) => {
    try {
        const createOrder = req.app.get('createOrderAction') as CreateOrderAction;

        const order = await createOrder.execute({
            customerId: req.user.id,
            items: req.body.items,
            paymentMethod: req.body.paymentMethod,
        });

        res.status(201).json({ order });
    } catch (error) {
        next(error);
    }
});
```

### Testing Node.js Actions

```typescript
describe('CreateOrderAction', () => {
    it('creates order and processes payment', async () => {
        // Mock dependencies
        const mockOrderService = {
            create: jest.fn().mockResolvedValue(mockOrder),
            markPaid: jest.fn(),
        };

        const mockPaymentService = {
            process: jest.fn().mockResolvedValue(mockPayment),
        };

        const mockEmailService = {
            sendOrderConfirmation: jest.fn(),
        };

        // Create action with mocked dependencies
        const action = new CreateOrderAction(
            mockOrderService as any,
            mockPaymentService as any,
            mockEmailService as any
        );

        // Execute
        const result = await action.execute({
            customerId: 'user-1',
            items: [{ id: 'item-1', quantity: 1, price: 100 }],
            paymentMethod: 'credit-card',
        });

        // Assert
        expect(mockOrderService.create).toHaveBeenCalled();
        expect(mockPaymentService.process).toHaveBeenCalled();
        expect(mockEmailService.sendOrderConfirmation).toHaveBeenCalled();
        expect(result).toEqual(mockOrder);
    });
});
```

## Symfony Action Pattern

### Symfony Service Action

```php
<?php

namespace App\Service\User;

use App\Entity\User;
use App\Repository\UserRepository;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

final readonly class CreateUserService {
    public function __construct(
        private UserRepository $userRepository,
        private UserPasswordHasherInterface $passwordHasher,
    ) {}

    public function execute(array $data): User {
        $user = new User();
        $user->setEmail($data['email']);
        $user->setName($data['name']);
        $user->setPassword(
            $this->passwordHasher->hashPassword($user, $data['password'])
        );

        $this->userRepository->save($user, flush: true);

        return $user;
    }
}
```

### Using in Symfony Controller

```php
class UserController extends AbstractController {
    public function create(
        Request $request,
        CreateUserService $createUser,
    ): Response {
        $user = $createUser->execute($request->getPayload()->all());

        return $this->json(['user' => $user], Response::HTTP_CREATED);
    }
}
```

## Naming Best Practices Across Frameworks

| Framework | Class Name | Method | Usage |
|-----------|-----------|--------|-------|
| Laravel | CreateUserAction | handle() | `$action->handle($data)` |
| React | useUserForm hook | (composition) | `const form = useUserForm()` |
| Vue | useUserForm composable | (composition) | `const form = useUserForm()` |
| Node.js | CreateUserService | execute() | `await service.execute(data)` |
| Symfony | CreateUserService | execute() | `$service->execute($data)` |

## Key Differences

**Laravel:**
- Class-based actions with `handle()` method
- Dependency injection via constructor
- Used in controllers, jobs, commands, API requests

**React:**
- Hooks for stateful logic
- Composition over inheritance
- Custom hooks are the "actions"

**Vue:**
- Composables for reusable logic
- Composition API similar to React hooks
- More flexible than React for state management

**Node.js:**
- Service classes with domain-specific methods
- Action classes for complex multi-step operations
- Similar to Laravel but named execute()

**Symfony:**
- Service-based approach similar to Laravel
- Dependency injection via constructor
- Used in controllers and commands
