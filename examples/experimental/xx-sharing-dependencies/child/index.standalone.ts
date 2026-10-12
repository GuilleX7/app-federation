import { mount } from "./entry.main.ts";

mount(document.body);

// import("./index.remote.ts").then(({ getEntry }) => {
//   getEntry("main").then(({ mount }) => {
//     mount(document.body);
//   });
// });
