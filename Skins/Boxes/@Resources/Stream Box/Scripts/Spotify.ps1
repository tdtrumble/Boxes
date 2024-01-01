param (
    [string]$apiKey,
    [string]$outputDirectory
)

$parts = $apiKey.Split(';')

# Get the part before the semicolon
$clientID = $parts[0]
$clientSecret = $parts[1]

# Define the API endpoint
$url = 'https://accounts.spotify.com/api/token'

# Define the request body
$body = @{
    grant_type    = 'client_credentials'
    client_id     = $clientID
    client_secret = $clientSecret
}

# Make the POST request
$response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers @{
    'Content-Type' = 'application/x-www-form-urlencoded'
}

$apiKey = $response.access_token

# Function to download an image
function Download-Image ($url, $outputPath) {
    Invoke-WebRequest -Uri $url -OutFile $outputPath
}

# clear the output directory
Remove-Item "$outputDirectory\*" -Force
Write-Host "Output directory cleared."

# Define the API endpoint and parameters
$url = 'https://api.spotify.com/v1/search?q=tag%3Anew&type=album&market=ES'

# Set the headers, including the Authorization token
$headers = @{
    'Authorization' = 'Bearer ' + $apiKey
}

# Make the GET request
$shows = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

# Iterate through the results and download posters
foreach ($show in $shows.albums.items) {
    $title = $show.name -replace '[^\w\s]', ''  # Remove special characters

    $posterUrl = $show.images.url[0]

    #Construct the output path
    $outputPath = Join-Path $outputDirectory "$title.jpg"

    #Download the image using your custom function (Download-Image)
    Download-Image -url $posterUrl -outputPath $outputPath

    Write-Host "Downloaded $title"
}