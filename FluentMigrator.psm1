function addMig
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [parameter(Position = 0,
            Mandatory = $true)]
        [string] $Description,
        [string] $ProjectName)
    $timestamp = (Get-Date -Format yyyyMMddHHmmss)
    $class_name_timestamp = (Get-Date -Format yyyyMMdd_HHmmss)
	$subfolder = (Get-Date -Format yyyyMM)
	

    if ($ProjectName) {
        $project = Get-Project $ProjectName
        if ($project -is [array])
        {
            throw "More than one project '$ProjectName' was found. Please specify the full name of the one to use."
        }
    }
    else {
        $project = Get-Project
    }
	
	$description_for_file_name = $Description.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    
	$class_name = "Mig_" + "$class_name_timestamp"
	$file_name = "Mig_" + "$class_name_timestamp" + "_" + "$env:UserName" + "_" + "$description_for_file_name"


    $namespace = $project.Properties.Item("DefaultNamespace").Value.ToString() + ".Migrations"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "Migrations", "$subfolder")
    $outputPath = [System.IO.Path]::Combine($migrationsPath, "$file_name" + ".cs")

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }

    "using FluentMigrator;

namespace $namespace
{
    [Migration($timestamp, `"$Description`")]
    public class $class_name : Migration
    {
        public override void Up()
        {
		            Execute.Sql(
@`"

--insert migration script here

`");
        }

        public override void Down()
        {
        }
    }
}" | Out-File -Encoding "UTF8" -Force $outputPath

    $project.ProjectItems.AddFromFile($outputPath)
    $project.Save($null)
	$DTE.ItemOperations.OpenFile("$outputPath",$DTE.Constants.vsViewKindTextView)
}

Export-ModuleMember @( 'addMig' )
