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
    
	$name = "Mig_" + "$class_name_timestamp"


    $namespace = $project.Properties.Item("DefaultNamespace").Value.ToString() + ".Migrations"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "Migrations")
    $outputPath = [System.IO.Path]::Combine($migrationsPath, "$name" + ".cs")

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }

    "using FluentMigrator;

namespace $namespace
{
    [Migration($timestamp, `"$Description`")]
    public class $name : Migration
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
}

Export-ModuleMember @( 'addMig' )
