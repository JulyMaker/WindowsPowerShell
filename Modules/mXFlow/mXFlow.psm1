####### MODULO XFLOW #######


Function conanenvironment 
{ 
    <#
    .SYNOPSIS
      Entra en conda, activa develop
    .DESCRIPTION 
      Entra en conda, activa develop
    
    .EXAMPLE 
      conanenvironment
    #> 

  (& "$env:Conda\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
  conda activate develop
}

Function xflowCompile 
{
   <#
    .SYNOPSIS
      Funcion para compilar xflow
    
    .DESCRIPTION 
      Permite hacer cmake, compilar y generar el deploy para el repositorio de xflow
    
    .EXAMPLE 
      xflowCompile
    .EXAMPLE 
      xflowCompile cmake / xflowCompile compile / xflowCompile deploy
    .EXAMPLE 
      xflowCompile full
    #> 

  Param( [ValidateSet("cmake","compile","deploy", "full")][string] $action = "default" ) 
  
  logo4
  $current = $pwd
  cd E:\git\xflowlegacy\common\win_compilation\steps
  conanenvironment

  switch($action)
  {
    "cmake"   { ./cmake_xflow2.bat }
    "compile" { ./compile_xflow.bat }
    "deploy"  { ./deploy_xflow.bat }
    "full"    { ./cmake_xflow2.bat; ./compile_xflow.bat; ./deploy_xflow.bat}
    default   {}
  }

  if($action -ne "default")
  {
    cd $current
  }

}

Function fmkInit
{ 

    <#
    .SYNOPSIS
      Funcion para repositorio fmk
    
    .DESCRIPTION 
      Permite inicializar, descargar y compilar el repositorio de fmk
    
    .EXAMPLE 
      fmkInit
    .EXAMPLE 
      fmkInit compile
    .EXAMPLE 
      fmkInit full
    #> 

  Param( [ValidateSet("init","compile","full")][string] $arg = "init" )

  $proflDir = ([system.io.fileinfo]$profile).DirectoryName
  $batsDir = "$proflDir\Scripts\cmdScripts\hide"

  if($arg -eq "init")
  {
    echo "FMK init"
    Start-Process cmd "/k $batsDir\alias.bat && $batsDir\fmkInit.bat"
  }
  elseif($arg -eq "compile")
  {
    echo "FMK compile"
    Start-Process cmd "/k $batsDir\alias.bat && $batsDir\fmkInit.bat && $batsDir\fmkCompile.bat" 
  }
  elseif($arg -eq "full")
  {
    echo "FMK init - download and compile"
    Start-Process cmd "/k $batsDir\alias.bat && $batsDir\fmkUpdate_Test.bat"
  }
   
}

Function traduccion 
{ 
    <#
    .SYNOPSIS
      Actualiza ficheros de traduccion de Xflow
    .DESCRIPTION 
      Actualiza ficheros de traduccion de Xflow
    
    .EXAMPLE 
      traduccion
    #> 

  $actual = $pwd
  cd "E:\git\xflowlegacy\gui\xflow-gui\resources\locale"
  translations_update_TS_files.bat
  translations_release_TS_files.bat
  
  cd $actual
}

Function papyrus
{
  <#
    .SYNOPSIS
      Abre papyrus para leer el repo
    .DESCRIPTION 
      Abre papyrus para leer el repo
    
    .EXAMPLE 
      papyrus
    #> 

  &"E:\papyrus\Papyrus\papyrus.exe" -vm "$env:ProgramFiles\Java\jdk-17\bin\server\jvm.dll" -i "E:\papyrus\papyrus-data-model-master"
}

Function compilar
{
   <#
    .SYNOPSIS
      Funcion para compilar en vs2019
    
    .DESCRIPTION 
      Permite compilar en vs2019 developer promp
    
    .EXAMPLE 
      compilar
    .EXAMPLE 
      compilar hello.cpp
    #> 

  Param( [string] $arg = "hello.cpp" )

  cl /W4 /EHsc $arg /link /out:progExe.exe
}

Function gui { cd E:\git\xflowlegacy}
Function steps { cd E:\git\xflowlegacy\common\win_compilation\steps}

Export-ModuleMember -function conanenvironment, xflowCompile, fmkInit, traduccion, papyrus, compilar, gui, steps