# windows_permissions

This script captures/re-applies permissions in windows of the provided location.

Parameters:

       -location  - location of the files. This parameter is mandatory and default value is C:
       -mode  => Mode/operation which accepts two values capture/reapply
              -capture to capture/record the folders and files permission recursively for the location
              -reapply the already captured folders and files permissions recursively to the location
              -This parameter is mandatory
        -dbLocation - Location to which the script can write the generated files
                         - default value is C:\TMP
                         - This parameter is optional
        -help        - Outputs the information about various available parameters

*The Parameters for the script are taken from here. The default values are set.*

# downloadArtifacts

download any artifacts given URLs and path to download.

