# log
$if_log = 0
$file_log = "C:\cmd\logoff.log"

# check run process
$powershell_process = 'PowerShell.exe'
$powershell_script = 'logoff.ps1'

# browser check
$chrome_process = 'chrome'
$iexplore_process = 'iexplore'
$yandex_process = 'browser'

$sleep = 10


# START
if ($if_log -eq 1) {
    $date = Get-Date
    Write-Output "$date;     =====================" | Out-File $file_log -Append
}



# check run process
# check lock file
if ((Get-WmiObject Win32_Process -Filter "name = '$powershell_process'" | Select-Object CommandLine | Where-Object { $_ -match $powershell_script } | measure).count -gt 1) {
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     Process already run, EXIT!" | Out-File $file_log -Append
        Write-Output "$date;     =====================" | Out-File $file_log -Append
    }
    exit
}



# session id
$whuser = whoami
$user = ($whuser -split '\\')[1]
$session_id = ((quser | Where-Object { $_ -match "^>$user\s+.+" }) -split ' +')[2]
if (-not $session_id) {
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     No user, EXIT!" | Out-File $file_log -Append
        Write-Output "$date;     =====================" | Out-File $file_log -Append
    }
    exit
}


# terminal
$term = ((quser | Where-Object { $_ -match $user }) -split ' +')[1]
if ($if_log -eq 1) {
    $date = Get-Date
    Write-Output "$date;     Terminal: $term; Session ID: $session_id" | Out-File $file_log -Append
}

if ( -not ($term -match '^rdp-.+$')) {
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     NOT RDP connection, EXIT!" | Out-File $file_log -Append
        Write-Output "$date;     =====================" | Out-File $file_log -Append
    }
    exit
}


# infinite loop

if ($if_log -eq 1) {
    $date = Get-Date
    Write-Output "$date;     RDP connection, START loop" | Out-File $file_log -Append
}

while ( $true) {

# process count
# chome
    $chrome_process_count = (Get-Process | Where-Object { $_ -match $chrome_process}).count
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     Chrome count: $chrome_process_count" | Out-File $file_log -Append
    }
# internet explorer
    $iexplore_process_count = (Get-Process | Where-Object { $_ -match $iexplore_process}).count
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     IExplore count: $iexplore_process_count" | Out-File $file_log -Append
    }
# yandex
    $yandex_process_count = (Get-Process | Where-Object { $_ -match $yandex_process}).count
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     Yandex count: $yandex_process_count" | Out-File $file_log -Append
    }

# определяем запущен ли браузер под терминальным пользователем
    $is_browser = 0
# chome
    if ($chrome_process_count -gt 0) {
        foreach ($item in Get-Process -Name $chrome_process) {
            if ($item.SessionId -eq $session_id) {
                $is_browser = 1
            }
        }
    }
# internet explorer
    if ($iexplore_process_count -gt 0) {
        foreach ($item in Get-Process -Name $iexplore_process) {
            if ($item.SessionId -eq $session_id) {
                $is_browser = 1
            }
        }
    }
# yandex
    if ($yandex_process_count -gt 0) {
        foreach ($item in Get-Process -Name $yandex_process) {
            if ($item.SessionId -eq $session_id) {
                $is_browser = 1
            }
        }
    }
    if ($if_log -eq 1) {
        $date = Get-Date
        Write-Output "$date;     is_browser = $is_browser" | Out-File $file_log -Append
    }

# logoff
    if ($is_browser-eq 0) {
        if ($if_log -eq 1) {
            $date = Get-Date
            Write-Output "$date;     LOGOFF!" | Out-File $file_log -Append
            Write-Output "$date;     =====================" | Out-File $file_log -Append
        }
        logoff $session_id
    }

# sleep
    Start-Sleep -Seconds $sleep

}

