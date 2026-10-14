const unsubscribe = bus.subscribe("cart:changed", (event: { count: number }) => {
  console.log("Cart changed:", event.count);
});

// When no longer interested in the "cart:changed" event:
unsubscribe();
