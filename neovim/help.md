# vim surround

## change surround
```shell
cs'"
```

## delete surround
```shell
ds"
```

## change tags (balise)
```shell
cst'
```

## add surround on word
```shell
ysiw]  => no space
ysiw[  => space
```

## add surround on line
```shell
yss]
```

## visual block surround

```shell
select and S]


:help text-objects

da” – D elete A round double quotes
di] – D elete I nside square brackets
ci{ – C hange I nside curly braces
dap – D elete A round P aragraph
vaw – V isually select A round W ord
```

# Fold

```shell
zf close fold under cursor
zo open fold
zR open all folds
zM close all open folds
za toggles the fold at the cursor
```

# Vim diff mode

```shell
:windo diffthis
:windo diffoff
```
