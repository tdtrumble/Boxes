param (
    [string]$apiKey,
    [string]$outputDirectory
)

# Get the current date
$currentDate = Get-Date

# Calculate the date 6 months ago
$sixMonthsAgo = $currentDate.AddMonths(-6)

# Format the date as 'yyyy-MM-dd'
$formattedDate = $sixMonthsAgo.ToString('yyyy-MM-dd')

# Function to download an image
function Download-Image ($url, $outputPath) {
    Invoke-WebRequest -Uri $url -OutFile $outputPath
}

# clear the output directory
Remove-Item "$outputDirectory\*" -Force
Write-Host "Output directory cleared."




# API request for movies
$response = Invoke-WebRequest -Uri "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&include_adult=false&include_video=false&language=en-US&page=1&primary_release_date.gte=$formattedDate&region=US&sort_by=popularity.desc&watch_region=US&with_original_language=en&with_watch_providers=384"

# Convert JSON response to PowerShell object
$movies = $response | ConvertFrom-Json

# Iterate through the results and download posters
foreach ($movie in $movies.results) {
    $title = $movie.title -replace '[^\w\s]', ''  # Remove special characters
    $posterPath = $movie.poster_path
    $posterUrl = "https://image.tmdb.org/t/p/original/$posterPath"
    
    # Construct the output path
    $outputPath = Join-Path $outputDirectory "$title.jpg"

    # Download the image
    Download-Image -url $posterUrl -outputPath $outputPath
	
    Write-Host "Downloaded $title"
}





# API request for tv
$response = Invoke-WebRequest -Uri "https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&first_air_date.gte=$formattedDate&include_adult=false&language=en-US&page=1&sort_by=popularity.desc&watch_region=ES&with_origin_country=US&with_watch_providers=384"

# Convert JSON response to PowerShell object
$shows = $response | ConvertFrom-Json

# Iterate through the results and download posters
foreach ($show in $shows.results) {
    $title = $show.name -replace '[^\w\s]', ''  # Remove special characters
    $posterPath = $show.poster_path
    $posterUrl = "https://image.tmdb.org/t/p/original/$posterPath"
    
    # Construct the output path
    $outputPath = Join-Path $outputDirectory "$title.jpg"

    # Download the image
    Download-Image -url $posterUrl -outputPath $outputPath
	
    Write-Host "Downloaded $title"
}