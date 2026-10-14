const locale = bridge.props.get("locale");
const unsubscribe = bridge.props.subscribe("locale", (newLocale) => {
  console.log("Locale updated:", newLocale);
});

// When no longer interested in updates for the "locale" prop:
unsubscribe();
// or unsubscribe from all props:
bridge.props.unsubscribeAll();
