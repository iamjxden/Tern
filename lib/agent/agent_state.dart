enum AgentState {
  idle,
  thinking,
  acting,
  finalizing,
  errored,
  stopped,
  interrupted;

  bool get isIdle => this == idle;
  bool get isRunning => this == thinking || this == acting || this == finalizing;
  bool get isTerminal => this == errored || this == stopped || this == interrupted;
  bool get canInterrupt => isRunning;
  bool get canRestart => isTerminal || isIdle;
}
