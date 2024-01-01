param (
    [string]$apiKey,
    [string]$outputDirectory
)

# Define the URL, in this case it's passed in as apiKey
$url = $apiKey

# grab rss data
$response = Invoke-RESTMethod -Uri $url

# Function to download an image
function Download-Image ($url, $outputPath) {
    Invoke-WebRequest -Uri $url -OutFile $outputPath
}

# clear the output directory
Remove-Item "$outputDirectory\*" -Force
Write-Host "Output directory cleared."

# Iterate through the results and download posters
foreach ($post in $response) {
    $title = $post.link #-replace '[^\w\s]', ''  #tweak permalink into a unique filename
	
	# Extract the desired information using the regex pattern
	if ($title -match ".*/post/(\d+)(?:/[^/]+)?/([^/]+)$") {
		$title = $Matches[2] + "-" + $Matches[1].Substring($Matches[1].Length - 3)
	} else {
		$title = $title.Substring($title.Length - 3, 3)
	}

	$posterUrl = ($post.description | Select-String -Pattern 'src="(https://[^"]+)"').Matches.Groups[1].Value
	
	#Construct the output path
    $outputPath = Join-Path $outputDirectory "$title.jpg"

    #Download the image using function (Download-Image)
    Download-Image -url $posterUrl -outputPath $outputPath
}