// import { mount } from "./entry.main.ts";
import { loadAppInstanceAndMount } from "examples-12-css-injection-library/runtime";

// mount({ container: document.body });

loadAppInstanceAndMount("remote.js", "app", { container: document.body });
