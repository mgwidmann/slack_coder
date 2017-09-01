defmodule SlackCoder.SignupTest do
  use Cabbage.Feature, file: "signup.feature", template: SlackCoder.Features.Case
  import_steps SlackCoder.Features.GlobalSteps

end
