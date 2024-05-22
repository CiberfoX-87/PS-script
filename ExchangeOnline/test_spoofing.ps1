###Test spoofing script###


# Verifica se Telnet è installato
$telnetInstalled = Get-WindowsFeature | Where-Object { $_.Name -eq "Telnet-Client" }

if ($telnetInstalled) {
    Write-Host "Telnet è già installato."
} else {
    Write-Host "Telnet non è installato. Procedo con l'installazione..."
    Install-WindowsFeature -Name Telnet-Client
    Write-Host "Telnet è stato installato con successo."
}

# Richiedi l'indirizzo email del mittente e del destinatario
$mittente = Read-Host "Inserisci l'indirizzo email del mittente"
$destinatario = Read-Host "Inserisci l'indirizzo email del destinatario"

# Estrai il dominio dal destinatario
$dominio = $destinatario.Split('@')[1]

# Ottieni gli MX records per il dominio
$mxRecords = Resolve-DnsName -Type MX -Name $dominio | Sort-Object Priority

# Se ci sono MX records, invia l'email tramite Telnet
if ($mxRecords) {
    $mxServer = $mxRecords[0].NameExchange
    Write-Host "Server MX trovato: $mxServer"
    
    # Connetti al server MX sulla porta 25 tramite Telnet
    telnet $mxServer 25
    
    # Invia i comandi SMTP per inviare l'email
    Write-Host "220 $mxServer Microsoft ESMTP MAIL Service ready"
    Write-Host "EHLO $dominio"
    Write-Host "MAIL FROM:<$mittente>"
    Write-Host "RCPT TO:<$destinatario>"
    Write-Host "DATA"
    Write-Host "Subject: Oggetto dell'email"
    Write-Host "Testo del messaggio"
    Write-Host "."
    Write-Host "QUIT"
} else {
    Write-Host "Nessun record MX trovato per il dominio $dominio"
}