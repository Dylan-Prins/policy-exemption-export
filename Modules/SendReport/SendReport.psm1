
function Get-AccessToken {
    [CmdletBinding()]
    param (
    # Parameter help description
    [Parameter()]
    [securestring]
    $ClientSecret
    )

    process {
        # replace with your application ID
        $clientId = 'a240b720-55c6-44fb-98ba-778ce7e31fb5'
        # replace with your tenant ID
        $tenantId = 'cd004ec9-bc4b-4721-82df-cd3a2e134a09'

        # DO NOT CHANGE ANYTHING BELOW THIS LINE
        $request = @{
            Method = 'POST'
            URI    = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
            body   = @{
                grant_type    = "client_credentials"
                scope         = "https://graph.microsoft.com/.default"
                client_id     = $clientId
                client_secret = $ClientSecret
            }
        }
        # Get the access token
        $token = (Invoke-RestMethod @request).access_token
        # view the token value
        $token
    }
}

function Send-Mail {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [securestring]
        $Token,

        # Parameter help description
        [Parameter()]
        [string]
        $FromAddress = 'dylan.prins@insparklabs.nl',

        # Parameter help description
        [Parameter()]
        [string]
        $ToAddress = 'dylan.prins@insparklabs.nl',

        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $Body
    )

    process {
        $mailSubject = 'Non-compliance report'

        $params = @{
            "URI"     = "https://graph.microsoft.com/v1.0/users/$fromAddress/sendMail"
            "Headers" = @{
                "Authorization" = ("Bearer {0}" -f $token)
            }
            "Method"  = "POST"
            "Content" = "application/json"
            "Body"    = (@{
                    "Message" = @{
                        "Subject"      = $mailSubject
                        "body"         = @{
                            "contentType" = "Text"
                            "content"     = $Body
                        }
                        "ToRecipients" = @(
                            @{
                                "emailAddress" = @{
                                    "address" = $toAddress
                                }
                            }
                        )
                    }
                }) | ConvertTo-Json -Depth 10
        }

        Invoke-RestMethod @params -Verbose
    }
}