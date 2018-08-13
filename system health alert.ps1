# ----- user variables--------------------
#customize these as required for environment
$parentdir = "C:\test" #where files from servers come in from on this enclave
#$emailto = CDSAdmins <user01@example.com> #Example "CDSAdmins <user01@example.com>"
#$emailfrom = CDSAdmins <user01@example.com> #Example "CDSAdmins <user01@example.com>"

# ----- variables--------------------

$monfiles = Get-Childitem -Path $parentdir\* -Include *.txt -Exclude "*report.txt"
$updates = Get-Childitem -Path $parentdir -Recurse -File -Exclude "*report.txt"
$reportcontent = Get-Content "$parentdir\report.txt"

# ----- create directory structure & sort files--------------------

if (!(Test-Path -Path $parentdir))
            {
            New-Item -Path $parentdir -ItemType Directory
            }

  foreach ($file in $monfiles.name)
    {
        $servername = $file.substring(0, $file.IndexOf('_'))
        if (!(Test-Path -Path $parentdir\$servername))
            {
            New-Item -Path $parentdir\$servername -ItemType Directory
            Move-Item -Path $parentdir\$file -Destination $parentdir\$servername
            }
            else
                {
                Move-Item -Path $parentdir\$file -Destination $parentdir\$servername
                }
    }

# ----- retrieve information from files & remove--------------------
# ----- there's three for each loops to separate the data correctly
  foreach ($update in $updates.fullname)
    {
      if ($update -ilike "*service.txt")
        {
          Get-Content $update | Out-File "$parentdir\report.txt" -noclobber -append
          Remove-Item -Path $update
        }
    }

  foreach ($update in $updates.fullname)
    {
      if ($update -ilike "*partition.txt")
        {
          Get-Content $update | Out-File "$parentdir\report.txt" -noclobber -append
          Remove-Item -Path $update
        }
    }

  foreach ($update in $updates.fullname)
    {
      if ($update -ilike "*thump.txt")
        {
          Get-Content $update | Out-File "$parentdir\report.txt" -noclobber -append
          Remove-Item -Path $update
        }
    }


# ----- send email to CDSAdmins--------------------

#Send-MailMessage -To "$emailto" -From "$emailfrom" -Subject "System Monitor" -Body "$reportcontent"

#monitored systems generate report every 10 minutes according to clock
#alerting system alerts every 5 minutes according to clock
