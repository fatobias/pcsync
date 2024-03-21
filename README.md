# pcsync
repo for system configuration storage a synchronization

the script duplicates does either:
./script_name push
-- the files and ziped directories defined in addresses file
-- are copied to ~/pcsync/data/ and subsequently push to the remote repository
-- it uses timedate in a commit message

./script_name pull
-- pulls from the remote repository and redistributes the files defined in addresses file
-- to their designated location.
-- this allows effortless config synchronization across multiple machines
