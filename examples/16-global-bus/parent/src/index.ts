import { createBus, loadAppInstanceEntry } from "../../library/dist/tools";
import { BusEvent, type BusEventPayload } from "../../contract";
import "./global.css";

document.body.innerHTML = `
  <h1>Parent</h1>
`;

const container = document.createElement("div");
container.style.border = "1px solid #000";
container.style.display = "block";
container.style.margin = "8px 0px";

const lastGreeting = document.createElement("p");
lastGreeting.innerText = "Last greeting from another app: none";

const bus = createBus<BusEventPayload>();
const unsubscribeFromHello = bus.subscribe(BusEvent.Hello, (greeting) => {
  if (greeting.sender !== "parent") {
    lastGreeting.innerText = `Last greeting from ${greeting.sender}`;
  }
});

const entry = await loadAppInstanceEntry("http://localhost:8081/remote.js");
await entry.mount({ container, bus });

const helloButton = document.createElement("button");
helloButton.innerText = "Send hello from parent";
helloButton.addEventListener("click", () => {
  bus.emit(BusEvent.Hello, {
    sender: "parent",
  });
});

document.body.append(lastGreeting, helloButton, container);
