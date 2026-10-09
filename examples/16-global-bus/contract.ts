export enum AppFederationBusEvent {
  ParentMessage = "parent-message",
  SubchildMessage = "subchild-message",
}

export type CommunicationEvents = {
  [AppFederationBusEvent.ParentMessage]: string;
  [AppFederationBusEvent.SubchildMessage]: string;
};
