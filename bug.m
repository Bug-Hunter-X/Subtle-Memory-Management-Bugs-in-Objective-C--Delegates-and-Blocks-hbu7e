In Objective-C, a common yet subtle issue arises when dealing with memory management and object lifecycles, especially when working with delegates or blocks.  Consider this scenario:

```objectivec
@interface MyClass : NSObject
@property (nonatomic, weak) id <MyDelegate> delegate;

- (void)someMethod;
@end

@implementation MyClass
- (void)someMethod {
    [self.delegate myDelegateMethod]; // Potential crash here if self.delegate is deallocated
}
@end
```

If `self.delegate` is deallocated before `someMethod` is called, sending a message to a deallocated object (`self.delegate myDelegateMethod`) will lead to a crash.  The `weak` property prevents retain cycles, but doesn't guarantee the delegate will outlive `MyClass`.

Another subtle issue can occur with blocks that retain their surrounding objects. This can lead to retain cycles. For example:

```objectivec
@interface MyClass : NSObject
@property (nonatomic, strong) void (^myBlock)(void);

- (void)someMethod {
    self.myBlock = ^{ [self doSomething]; };
}

- (void)doSomething {
  //some code
}
@end
```

Here, `myBlock` retains `self`, preventing `self` from being deallocated even after it's no longer needed. If this is not what is desired, you would need to utilize `__weak` or weak `self` inside the block, using `__weak typeof(self) weakSelf = self;`

These issues are often hard to debug because they manifest as seemingly random crashes or unexpected behavior. 