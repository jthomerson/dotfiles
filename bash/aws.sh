export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

alias AWSUnset='unset $(env | grep AWS | grep -v AWS_REGION | grep -v AWS_DEFAULT_REGION | sed '"'"'s|=.*||'"'"')'
alias unsetAWS='unset $(env | grep AWS | grep -v AWS_REGION | grep -v AWS_DEFAULT_REGION | sed '\''s|=.*||'\'')'

# TODO: auto-completion, TOTP / role assumption
# complete -C '$(which aws_completer)' aws


# For awsume (https://awsu.me)
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
# (https://docs.commonfate.io/granted/troubleshooting/#manually-configuring-your-shell-profile)
function assume {
   source assume $@
   # Serverless (SLS) fails when AWS_PROFILE is set, so we unset it here
   unset AWS_PROFILE
}

alias grantedClear='granted sso-tokens clear'

function assumeRemote {
   cp ~/.granted/config ~/.granted/config.bak
   sed -i 's/CustomSSOBrowserPath.*/CustomSSOBrowserPath = "THIS_BROWSER_DOES_NOT_EXIST"/' ~/.granted/config
   source assume $@
   unset AWS_PROFILE
   mv ~/.granted/config.bak ~/.granted/config
}
