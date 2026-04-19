export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

alias AWSUnset='unset $(env | grep AWS | grep -v AWS_REGION | grep -v AWS_DEFAULT_REGION | sed '"'"'s|=.*||'"'"')'
alias unsetAWS='unset $(env | grep AWS | grep -v AWS_REGION | grep -v AWS_DEFAULT_REGION | sed '\''s|=.*||'\'')'

# TODO: auto-completion, TOTP / role assumption
# complete -C '$(which aws_completer)' aws


# For awsume (https://awsu.me)
# Note: `complete -F` and `compgen` work in zsh via bashcompinit, which is loaded in rc.sh
alias awsume=". awsume"

_awsume() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(awsume-autocomplete)
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _awsume awsume
complete -F _awsume AWS

# For Granted
# (https://docs.commonfate.io/granted/internals/shell-alias)
# Granted's `assume` script detects the shell-integration wrapper by running
# `type -- assume` and matching "alias" or "not found". A bare function wouldn't
# match, so we wrap the function in an alias: `type -- assume` reports an alias,
# Granted's supported detection path passes, and our cleanup still runs.
unalias assume 2>/dev/null
_assume_granted() {
   source assume "$@"
   # Serverless (SLS) fails when AWS_PROFILE is set, so we unset it here
   unset AWS_PROFILE
}
alias assume=_assume_granted

alias grantedClear='granted sso-tokens clear'
