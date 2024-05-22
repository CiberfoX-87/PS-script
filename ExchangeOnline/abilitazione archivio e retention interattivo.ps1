# Lo script richiede una corretta configurazione del nome della regola presente sulle regole di live cycle su MRM
# Lo script richiede una connessione già attiva con il server exchange online ed i relativi moduli installati
# I parametri che richiedono una configurazione manuale sono indicati con la seguente stringa XXXXXXXX
# path file csv (La colonna deve chiamarsi EmailAddress) 


Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.filter = "CSV files (*.csv)|*.csv"
$result = $openFileDialog.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $csvFilePath = $openFileDialog.FileName
    # Ora puoi usare la variabile $csvPath per accedere al percorso del file CSV
    Write-Host "Il percorso del file selezionato è: $csvPath"
} else {
    Write-Host "Nessun file è stato selezionato."
}



# Legge il file e lo serializza
$mailboxEmailAddresses = Import-Csv -Path $csvFilePath | ForEach-Object { $_.EmailAddress }

# Sale su Exchange
$UserCredential = Get-Credential
Connect-ExchangeOnline -UserPrincipalName $UserCredential.UserName -ShowProgress $true


function Show-Menu {
    param (
        [string]$Title = 'Seleziona un'opzione:'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    Write-Host "1: Abilita XXXXXXXX"
    Write-Host "2: Disabilita XXXXXXXX"
    Write-Host "Q: Esci"
}

$selection = $null
do {
    Show-Menu
    $selection = Read-Host "Per favore, inserisci la tua scelta"
    switch ($selection) {
        '1' {
            Write-Host "Hai selezionato l'Opzione 1"
           # Abilita archivio e setta la policy (la policy deve essere creata prima dell'applicazione)
foreach ($emailAddress in $mailboxEmailAddresses) {
    Enable-Mailbox -Identity $emailAddress -Archive
    # Imposta la policy di retention
    Set-Mailbox -Identity $emailAddress -RetentionPolicy "XXXXXXXX"
    #Esegue il force
    Start-ManagedFolderAssistant $emailAddress
}
        }
        '2' {
            Write-Host "Hai selezionato l'Opzione 2"
            # Abilita archivio e setta la policy (la policy deve essere creata prima dell'applicazione)
foreach ($emailAddress in $mailboxEmailAddresses) {
    Enable-Mailbox -Identity $emailAddress -Archive
    # Imposta la policy di retention
    Set-Mailbox -Identity $emailAddress -RetentionPolicy "Default MRM Policy"
    #Esegue il force
    Start-ManagedFolderAssistant $emailAddress
}
        }
        'Q' {
            return
        }
        default {
            Write-Host "Selezione non valida. Per favore, prova di nuovo."
        }
    }
    pause
} while ($selection -ne 'Q')


# Sgancia exchange
Disconnect-ExchangeOnline -Confirm:$false

# Stampa un messaggio di successo
Write-Host "L'archiviazione delle email è stata abilitata, la retention policy è stata impostata per le caselle elencate in $csvFilePath."
