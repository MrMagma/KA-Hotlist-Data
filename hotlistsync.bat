REM Setup our variables and stuff.
set "logfile=errors.log"

if NOT EXIST %logfile% type nul > %logfile%
if NOT EXIST %1 mkdir %1

set "timestamp=%date:~0,4%-%date:~5,2%-%date:~8,2%-%time:~0,2%%time:~3,2%"
set apilink="http://www.khanacademy.org/api/internal/scratchpads/top?casing=camel&topic_id=xffde7c31&sort=3&subject=all&limit=20&page=0&lang=en"

REM Get the hotlist data and output it to a timestamped file
curl %apilink% --connect-timeout 10 > "%1/hotlist_%timestamp%.json" 2>> %logfile% && (
    echo Hotlist successfully synced! Running GitHub sync...
) || (
    echo An error occured while fetching the hotlist and has been logged to %logfile%
    echo {}> "%1/hotlist_%timestamp%.json"
    goto end
)

REM Just make for super-sure that we have a git repository to commit to
if NOT exist .git (
    echo No .git folder found. Initializing git repository...
    git init
    git remote add origin %2
)

REM Commit our newly synced data to git.
git add -A
git commit -m "Hotlist snapshot for %timestamp%"

:end
