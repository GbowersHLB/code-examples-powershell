# Get required environment variables from .\config\settings.json file
$accessToken = Get-Content .\config\ds_access_token.txt
$APIAccountId = Get-Content .\config\API_ACCOUNT_ID


# Step 2 Start
# Construct your API headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.add("Authorization", "Bearer $accessToken")
$headers.add("Accept", "application/json")
$headers.add("Content-Type", "application/json")
# Step 2 End

# Step 3 Start
# Construct the request body
$body = @"
  {
    "name": "Sample Room Form Group"
  }
"@
# Step 3 End

# Step 4 Start
# Call the Rooms API
$base_path = "https://demo.rooms.docusign.com"
$uri = "$base_path/restapi/v2/accounts/$APIAccountId/form_groups"

try {
    Write-Output "Response:"
    $response = Invoke-WebRequest -uri $uri -headers $headers -method POST -body $body
    $response.Content
    $obj = $response.Content | ConvertFrom-Json
    $formGroupID = $obj.formGroupId

    # Store formGroupID into the file .\config\FORM_GROUP_ID
    $formGroupID > .\config\FORM_GROUP_ID
}
catch {
    Write-Output "Unable to create a form group"
    # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error

    foreach ($header in $_.Exception.Response.Headers) {
        if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
        $int++
    }
    Write-Output "Error : "$_.ErrorDetails.Message
    Write-Output "Command : "$_.InvocationInfo.Line
}
# Step 4 End
