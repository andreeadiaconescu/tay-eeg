
JG notes on MMN experiment code changes for TAY
================================================

10-02-2021

Over the past 2 weeks I introduced a number of changes to a small portion of the original experiment code. 
This was done in something of a rush in order to get as quickly as possible to a working experiment. 

Now we are just about there, taking a bit of time to document some key points, and make suggestions on next steps. 



## 1. Code organization

I've come up with (I think) a sensible organizational structure, whereby the general eeg lab docs live at 
www.github.com/krembilneuroinformatics/kcni-eeg-lab, 
and documentation and code for specific experiments live in separate github repos (such as this one), 
which exist as submodules in the `kcni-eeg-lab/studies` folder. 



## 2. Folder structure for this repo

Suggesting the following folder structure for this repo (to be consistent across all kcni eeg lab studies)

`tay-eeg/code/experiment`
`tay-eeg/code/analysis` 

and maybe something like 

`tay-eeg/docs/experiment_instructions.md`

But this is just a suggestion. 


## 3. New launch script

run_tay_eeg_expt.m

## 4. Cedrus response box

[to add]

## 5. Biosemi trigger tool

[ to add ] 

## 6. Filepaths in code

[ to add ] 

## 7. Dealing with matlab crashing
  
[ to add ]   
  




