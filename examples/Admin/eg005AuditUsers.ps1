# Get required environment variables from .\config\settings.json file
$accessToken = Get-Content .\config\ds_access_token.txt
$APIAccountId = Get-Content .\config\API_ACCOUNT_ID

# Get required variables from .\config\settings.json file
$variables = Get-Content .\config\settings.json -Raw | ConvertFrom-Json

$base_path = "https://api-d.docusign.net/management"
$organizationId=$variables.ORGANIZATION_ID

# Check that organizationId has been set
if($null -eq $organizationId)
{
  Write-Output "PROBLEM: Please add your ORGANIZATION_ID to settings.json."
  Exit
}

# Construct your API headers
# Step 2 start
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.add("Authorization", "Bearer $accessToken")
$headers.add("Accept", "application/json")
$headers.add("Content-Type", "application/json")
# Step 2 end

# Step 3 Start
$modifiedSince = (Get-Date (Get-Date).AddDays(-10) -Format "yyyy-MM-dd")

try {
  # Display the JSON response
  Write-Output "Response:"
  $uri = "${base_path}/management/v2/organizations/${organizationId}/users?account_id=${APIAccountId}&last_modified_since=${modifiedSince}"
  $response = Invoke-WebRequest -uri $uri -UseBasicParsing -headers $headers -method GET
  $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 4
  $modifiedUsers = $($response.Content | ConvertFrom-Json).users
}
catch {
  Write-Output "Error:"
  # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error
  foreach ($header in $_.Exception.Response.Headers) {
    if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
    $int++
  }
  Write-Output "Error : "$_.ErrorDetails.Message
  Write-Output "Command : "$_.InvocationInfo.Line
  exit 1
}
# Step 3 end

# Step 4 start
$userEmails = $modifiedUsers.email
# Step 4 end

# Step 5 start
foreach ($emailAddress in $userEmails){
  try {
    # Display the JSON response
    Write-Output "Response:"
    $uri = "${base_path}/management/v2/organizations/${organizationId}/users/profile?email=${emailAddress}"
    $response = Invoke-WebRequest -uri $uri -UseBasicParsing -headers $headers -method GET
    $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 4
  }
  catch {
    Write-Output "Error:"
    # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error
    foreach ($header in $_.Exception.Response.Headers) {
      if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
      $int++
    }
    Write-Output "Error : "$_.ErrorDetails.Message
    Write-Output "Command : "$_.InvocationInfo.Line
    exit 1
  }
}
# Step 5 end