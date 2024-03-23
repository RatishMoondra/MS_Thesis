# Initialize the since parameter
$since = 562500000
$fileCounter = 1

# Create the subfolder if it doesn't exist
$folderPath = ".\stocktwits"
if (-not (Test-Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

# Infinite loop
while ($true) {
    # Define the output file path
    $outputFilePath = Join-Path -Path $folderPath -ChildPath ("output-$fileCounter.json")

    # Prompt the user to start the data fetching loop
    Write-Host "Press Enter to start fetching data from Stocktwits API and save to $($outputFilePath)..."
    $null = Read-Host

    # Make a request to the Stocktwits API using Invoke-RestMethod
    $response = Invoke-RestMethod -ContentType "application/json; charset=utf-8" -Uri "https://api.stocktwits.com/api/2/streams/symbol/AAPL.json?since=$since&limit=30"
    #Check if the response is null or empty
    if ($response -eq $null) {
        Write-Host "Response is null or empty"
        return
    }

    # $jsonContent = [Text.Encoding]::UTF8.GetString($response.ToArray())

    # Check if the request was successful
    if ($response) {
        # Extract the last ID from the response and update the since parameter
        $since = $response.messages[-1].id

        # Append the response to the output file
        $response | ConvertTo-Json -Depth 100 | Out-File -FilePath $outputFilePath -Encoding Ascii
        
        Write-Host "Next since parameter: $since"

        # Increment the file counter
        $fileCounter++

        # Prompt the user to continue or exit the loop
        Write-Host "Press Enter to continue fetching data or type 'exit' to stop..."
        $input = Read-Host
        if ($input -eq "exit") {
            break
        }
    }
    else {
        Write-Host "Error making request"
    }

    # # Read the content of the file and remove the BOM
    # $content = Get-Content -Path $outputFilePath -Encoding Utf8
    # $content | Set-Content -Path $outputFilePath -Encoding Utf8 -NoNewline
    
    # Sleep for a while before making the next request (rate limiting)
    Start-Sleep -Seconds 1
}

