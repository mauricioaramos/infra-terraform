add-content -path c:/users/MauRamos/.ssh/config -value @'

Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${IdentityFile}
'@