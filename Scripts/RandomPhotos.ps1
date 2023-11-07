############## Random Photos ####################
<#PSScriptInfo

.VERSION 1.0

.GUID 0ddaf117-a49a-45b2-9914-56639bf8890b

.AUTHOR Julio Martin
.COMPANYNAME 
.COPYRIGHT 

.TAGS
 RandomPhotos

.LICENSEURI 
.PROJECTURI 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES

.DESCRIPTION 
 	RandomPhotos default equal 1
.EXAMPLE 
  RandomPhotos $numSelectedPhotos
 
#> 

	  PARAM($randomN=1)

	  $files = ls -name
	  $numPhotos = $files.Count

	  $fotos = random -InputObject @(0..$numPhotos) -Count $randomN
	 
	  $folderPath = ".\selected"
	  $folderExists = Test-Path $folderPath -PathType Container
      if(! $folderExists){mkdir $folderPath}

      foreach ( $foto in $fotos )
      { 
        $file = $files[$foto]
        Copy-Item .\$file -Destination .\selected\$file
      }