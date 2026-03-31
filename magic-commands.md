# install needed libs 

## first way

pip install ipython-sqlcmd(this wont support windows auth)


## how magic commands are working..

pip install ipython-sqlcmd        ← installs the PACKAGE to your system
        ↓
%load_ext sqlcmd                  ← loads that package INTO your notebook session
        ↓
%%sqlcmd                          ← now you can USE it in your cells

## second way

pip install ipython-sql sqlalchemy pyodbc

