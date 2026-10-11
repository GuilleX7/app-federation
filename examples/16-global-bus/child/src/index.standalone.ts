import { createBus, loadAppInstanceEntry } from "../../library/dist/tools";
import { BusEvent, type BusEventPayload } from "../../contract";

const bus = createBus<BusEventPayload>();
const helloButton = document.createElement("button");
helloButton.innerText = "Send hello from child";
helloButton.addEventListener("click", () => {
  bus.emit(BusEvent.Hello, {
    sender: "child",
  });
});
document.body.appendChild(helloButton);

loadAppInstanceEntry("remote.js")
  .then(async (entry) => {
    await entry.mount({ container: document.body, bus });
  })
  .catch((error: unknown) => {
    console.error("Failed to load the standalone microfrontend.", error);
  });
