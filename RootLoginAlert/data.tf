data "archive_file" "python_lambda_package" {
  type          = "zip"  	
  source_file   = "./RootActivityLambda.py" 	
  output_path   = "RootActivityLambda.zip"	
}	