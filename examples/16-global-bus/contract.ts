export enum BusEvent {
  Hello = "hello",
}

export type BusEventPayload = {
  [BusEvent.Hello]: {
    sender: string;
  };
};
