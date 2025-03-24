# UC3M Files and Databases Lab 2: 
Triggers, Queries, External and operativity. 

## Running code in the database:
The database used for this project is OracleSQL. To access it it's required to use Aula Virtual and connect to the VM provided by the university.
Because copying and pasting the code over and over again is not productive and a waste of time the following method is recommended:

1. Edit all the code in the files provided in the repository.
2. Clone the repository in the VM. (The repo is public in order to do this easily)
3. Open the slqPlus terminal and enter credentials
4. Run the code in the database using the following command:
```sql
@/path/to/file.sql
```
Normally, the path to the file will be something like `/home/username/UC3M-Files-and-Databases-Lab-2/src/module/file.sql`

5. For each edition of the code, perform a git push locally and then pull the changes in the VM before execution. 

### Running the initial code (start)
The initial code provided in the repository is the code to initialize the database. This code is provided by the university and can be run using the same method described avobe. The files are located in `res/start/NEW_creation.sql` `res/start/NEW_load.sql` so just use the command `@/path/to/file.sql` to run them before anything else.



## Structure of the repository:
The repository is structured in the following way:
- `src/` contains all the code for the project.
- `src/moduleName/` Each part of the proyect has its own folder with its code.
- 'res/' contains the resources used in the project. Mainly the assignment with the problem description and **the provided code to initialize the database in order to perform all operations required**. 
- `100495811_100495711_100495775.docx` is the report of the project. This report can be eddited (and should be) directly on google drive. The final report must be a PDF file generated from this docx file. 
