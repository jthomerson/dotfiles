export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

alias AWSUnset='unset $(env | grep AWS | grep -v AWS_REGION | grep -v AWS_DEFAULT_REGION | sed '"'"'s|=.*||'"'"')'

# TODO: auto-completion, TOTP / role assumption
# complete -C '$(which aws_completer)' aws
