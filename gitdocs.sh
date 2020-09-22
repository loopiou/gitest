git checkout -- <file>   # 丢弃工作区的修改
git checkout <branch>  # 切换到指定的分支，不会去修改你在Working Directory里修改过的文件

git reflog  # 记录你的每一次命令

# 注意：已经push到远端仓库的，就不要再reset了，使用 revert 来替代
git reset <file>    # 把暂存区的修改回退到工作区，与下面两句等效（带有file参数的reset指令不能指定soft和hard选项）
git reset HEAD <file>
git reset --mixed HEAD <file>

git reset --soft HEAD^   # 把HEAD指向上一次提交，暂存区和工作区不变
git reset --mixed HEAD^  # 把HEAD指向上一次提交，并把HEAD^的内容同步到暂存区，工作区不变（默认选项）
git reset --hard HEAD^   # 把HEAD指向上一次提交，并把HEAD^的内容同步到暂存区和工作区（工作区做过的修改会被覆盖）
                         # 如果reset --hard 指向了另一个分支的某个提交，reset把branch移动到指定的地方

git rm <file>  # 删除文件（误删后，可以使用 git checkout -- <file> 来恢复）


git remote add origin git@server-name:path/repo-name.git  # 关联一个远程库
git remote rm origin  # 删除远程库 origin

# 由于远程库是空的，我们第一次推送master分支时，加上了-u参数，Git不但会把本地的master分支内容推送的远程新的master分支，
# 还会把本地的master分支和远程的master分支关联起来，在以后的推送或者拉取时就可以简化命令。
git push -u origin master

git checkout -b dev  # 创建dev分支，然后切换到dev分支（git checkout命令加上-b参数表示创建并切换，相当于以下两条命令）
git branch dev
git checkout dev

git switch -c dev  # 新版本中，可以使用switch来替代checkout，本句等效于 git checkout -b dev

git branch  # 查看当前分支

git checkout master  # 切换回master分支
git switch master    # 等效于 git checkout master

git merge dev  # 把dev分支的工作成果合并到master分支上（合并指定分支到当前分支）
git branch -d dev  # 删除dev分支
git branch -D <name>  # 丢弃一个没有被合并过的分支（强行删除）


# 强制禁用Fast forward模式（--no-ff方式的git merge），Git就会在merge时生成一个新的commit，
# 这样，从分支历史上就可以看出分支信息。
# 合并分支时，加上--no-ff参数就可以用普通模式合并，合并后的历史有分支，能看出来曾经做过合并，而fast forward合并就看不出来曾经做过合并。
git merge --no-ff -m "merge with no-ff" dev

# 分支策略
# 在实际开发中，我们应该按照几个基本原则进行分支管理：
# 首先，master分支应该是非常稳定的，也就是仅用来发布新版本，平时不能在上面干活；
# 那在哪干活呢？干活都在dev分支上，也就是说，dev分支是不稳定的，到某个时候，比如1.0版本发布时，再把dev分支合并到master上，在master分支发布1.0版本；
# 你和你的小伙伴们每个人都在dev分支上干活，每个人都有自己的分支，时不时地往dev分支上合并就可以了。


git stash  # 把当前工作现场“储藏”起来，等以后恢复现场后继续工作
git stash list  # 查看所有的 stash

git stash pop                 # 恢复的同时把stash内容也删了（等效于下面两句）
git stash apply 'stash@{0}'   # 恢复指定的 stash
git stash drop 'stash@{0}'    # 删除指定的 stash


# 同样的bug，要在dev上修复，我们只需要把 642245d 这个提交所做的修改“复制”到dev分支。
# 注意：我们只想复制 642245d 这个提交所做的修改，并不是把整个master分支merge过来。
# 为了方便操作，Git专门提供了一个cherry-pick命令，让我们能复制一个特定的提交到当前分支
git cherry-pick 642245d  # 复制一个特定的提交到当前分支


# -----------------------------------------多人协作-----------------------------------------
# 当你从远程仓库克隆时，实际上Git自动把本地的master分支和远程的master分支对应起来了，并且，远程仓库的默认名称是origin。
git remote [-v]  # 要查看远程库的信息，-v显示更详细的信息（如果没有推送权限，就看不到push的地址）

# 推送分支，就是把该分支上的所有本地提交推送到远程库。推送时，要指定本地分支，这样，Git就会把该分支推送到远程库对应的远程分支上：
git push origin dev  # 推送 dev 分支到远程库对应的远程分支上

# 当你的小伙伴从远程库clone时，默认情况下，你的小伙伴只能看到本地的master分支。不信可以用git branch命令看看
# 现在，你的小伙伴要在dev分支上开发，就必须创建远程origin的dev分支到本地，于是他用这个命令创建本地dev分支，
# 之后，他就可以在dev上继续修改，然后，时不时地把dev分支push到远程(本地和远程分支的名称最好一致)：
git checkout -b dev origin/dev  # 创建本地分支

# 你的小伙伴已经向origin/dev分支推送了他的提交，而碰巧你也对同样的文件作了修改，并试图推送：
# 推送失败，因为你的小伙伴的最新提交和你试图推送的提交有冲突，解决办法也很简单，Git已经提示我们，
# 先用git pull把最新的提交从origin/dev抓下来，然后，在本地合并，解决冲突，再推送
git pull
# git pull也失败了，原因是没有指定本地dev分支与远程origin/dev分支的链接，根据提示，设置dev和origin/dev的链接
git branch --set-upstream-to=origin/dev dev  # 关联本地分支与远程分支
# 这回git pull成功，但是合并有冲突，需要手动解决，解决的方法和分支管理中的解决冲突完全一样。解决后，提交，再push

# 因此，多人协作的工作模式通常是这样：
# 1、首先，可以试图用git push origin <branch-name>推送自己的修改；
# 2、如果推送失败，则因为远程分支比你的本地更新，需要先用git pull试图合并；
# 3、如果合并有冲突，则解决冲突，并在本地提交；
# 4、没有冲突或者解决掉冲突后，再用git push origin <branch-name>推送就能成功！
# 5、如果git pull提示no tracking information，则说明本地分支和远程分支的链接关系没有创建，
#   用命令git branch --set-upstream-to <branch-name> origin/<branch-name>。
# 这就是多人协作的工作模式，一旦熟悉了，就非常简单。
# 小结：
# 查看远程库信息，使用git remote -v；
# 本地新建的分支如果不推送到远程，对其他人就是不可见的；
# 从本地推送分支，使用git push origin branch-name，如果推送失败，先用git pull抓取远程的新提交；
# 在本地创建和远程分支对应的分支，使用git checkout -b branch-name origin/branch-name，本地和远程分支的名称最好一致；
# 建立本地分支和远程分支的关联，使用git branch --set-upstream branch-name origin/branch-name；
# 从远程抓取分支，使用git pull，如果有冲突，要先处理冲突。


# ------------------------------------------标签管理----------------------------------------------
# 发布一个版本时，我们通常先在版本库中打一个标签（tag），这样，就唯一确定了打标签时刻的版本。将来无论什么时候，取某个标签的版本，
# 就是把那个打标签的时刻的历史版本取出来。所以，标签也是版本库的一个快照。
# Git的标签虽然是版本库的快照，但其实它就是指向某个commit的指针（跟分支很像对不对？但是分支可以移动，标签不能移动），
# 所以，创建和删除标签都是瞬间完成的。
# Git有commit，为什么还要引入tag？
# “请把上周一的那个版本打包发布，commit号是6a5819e...”
# “一串乱七八糟的数字不好找！”
# 如果换一个办法：
# “请把上周一的那个版本打包发布，版本号是v1.2”
# “好的，按照tag v1.2查找commit就行！”
# 所以，tag就是一个让人容易记住的有意义的名字，它跟某个commit绑在一起。
git tag v1.0  # 打上一个 v1.0 的标签

# 默认标签是打在最新提交的commit上的。有时候，如果忘了打标签，比如，现在已经是周五了，但应该在周一打的标签没有打，怎么办？
# 方法是找到历史提交的commit id，然后打上就可以了：
git log --pretty=oneline --abbrev-commit
git tag v0.9 f52c633  # 对 f52c633 这次提交打上 v0.9 的标签
git tag  # 列出标签

# 注意，标签不是按时间顺序列出，而是按字母排序的。可以用git show <tagname>查看标签信息
git show v0.9
# 还可以创建带有说明的标签，用-a指定标签名，-m指定说明文字：
git tag -a v0.1 -m "version 0.1 released" 1094adb

# 小结
# 命令git tag <tagname>用于新建一个标签，默认为HEAD，也可以指定一个commit id；
# 命令git tag -a <tagname> -m "blablabla..."可以指定标签信息；
# 命令git tag可以查看所有标签。

git tag -d v0.1  # 如果标签打错了，也可以删除
# 因为创建的标签都只存储在本地，不会自动推送到远程。所以，打错的标签可以在本地安全删除。
# 如果要推送某个标签到远程，使用命令git push origin <tagname>：
git push origin v1.0
# 或者，一次性推送全部尚未推送到远程的本地标签
git push origin --tags

# 如果标签已经推送到远程，要删除远程标签就麻烦一点，先从本地删除：
git tag -d v0.9
# 然后，从远程删除。删除命令也是push，但是格式如下：
git push origin :refs/tags/v0.9

# 小结
# 命令git push origin <tagname>可以推送一个本地标签；
# 命令git push origin --tags可以推送全部未推送过的本地标签；
# 命令git tag -d <tagname>可以删除一个本地标签；
# 命令git push origin :refs/tags/<tagname>可以删除一个远程标签。



# ------------------------------------------rebase----------------------------------------------
# 在上一节我们看到了，多人在同一个分支上协作时，很容易出现冲突。即使没有冲突，后push的童鞋不得不先pull，在本地合并，然后才能push成功。
# 每次合并再push后，分支变成了这样：
git log --graph --pretty=oneline --abbrev-commit
    * d1be385 (HEAD -> master, origin/master) init hello
    *   e5e69f1 Merge branch 'dev'
    |\
    | *   57c53ab (origin/dev, dev) fix env conflict
    | |\
    | | * 7a5e5dd add env
    | * | 7bd91f1 add new env
    | |/
    * |   12a631b merged bug fix 101
    |\ \
    | * | 4c805e2 fix bug 101
    |/ /
    * |   e1e9c68 merge with no-ff
    |\ \
    | |/
    | * f52c633 add merge
    |/
    *   cf810e4 conflict fixed
# 总之看上去很乱，有强迫症的童鞋会问：为什么Git的提交历史不能是一条干净的直线？
# 其实是可以做到的！
# Git有一种称为rebase的操作，有人把它翻译成“变基”。

# 在和远程分支同步后，我们对hello.py这个文件做了两次提交。用git log命令看看：
$ git log --graph --pretty=oneline --abbrev-commit
    * 582d922 (HEAD -> master) add author
    * 8875536 add comment
    * d1be385 (origin/master) init hello
    *   e5e69f1 Merge branch 'dev'
    |\
    | *   57c53ab (origin/dev, dev) fix env conflict
    | |\
    | | * 7a5e5dd add env
    | * | 7bd91f1 add new env
    ...
# 注意到Git用(HEAD -> master)和(origin/master)标识出当前分支的HEAD和远程origin的位置分别是
# 582d922 add author和d1be385 init hello，本地分支比远程分支快两个提交。
# 现在我们尝试推送本地分支：
git push origin master
# 很不幸，失败了，这说明有人先于我们推送了远程分支。按照经验，先pull一下：
git pull
# 加上刚才合并的提交，现在我们本地分支比远程分支超前3个提交。
$ git log --graph --pretty=oneline --abbrev-commit
    *   e0ea545 (HEAD -> master) Merge branch 'master' of github.com:michaelliao/learngit
    |\
    | * f005ed4 (origin/master) set exit=1
    * | 582d922 add author
    * | 8875536 add comment
    |/
    * d1be385 init hello

# 对强迫症童鞋来说，现在事情有点不对头，提交历史分叉了。如果现在把本地分支push到远程，有没有问题？
# 有！
# 什么问题？
# 不好看！
# 有没有解决方法？
# 有！
# 这个时候，rebase就派上了用场。我们输入命令git rebase试试：
git rebase
# 输出了一大堆操作，到底是啥效果？再用git log看看：
$ git log --graph --pretty=oneline --abbrev-commit
    * 7e61ed4 (HEAD -> master) add author
    * 3611cfe add comment
    * f005ed4 (origin/master) set exit=1
    * d1be385 init hello
    ...

# 原本分叉的提交现在变成一条直线了！这种神奇的操作是怎么实现的？其实原理非常简单。我们注意观察，发现Git把我们本地的提交“挪动”了位置，
# 放到了f005ed4 (origin/master) set exit=1之后，这样，整个提交历史就成了一条直线。rebase操作前后，最终的提交内容是一致的，
# 但是，我们本地的commit修改内容已经变化了，它们的修改不再基于d1be385 init hello，而是基于f005ed4 (origin/master) set exit=1，
# 但最后的提交7e61ed4内容是一致的。
# 这就是rebase操作的特点：把分叉的提交历史“整理”成一条直线，看上去更直观。缺点是本地的分叉提交已经被修改过了。
# 最后，通过push操作把本地分支推送到远程：
git push origin master
# 再用git log看看效果：
git log --graph --pretty=oneline --abbrev-commit
    * 7e61ed4 (HEAD -> master, origin/master) add author
    * 3611cfe add comment
    * f005ed4 set exit=1
    * d1be385 init hello
    ...
# 远程分支的提交历史也是一条直线。

# 小结
# rebase操作可以把本地未push的分叉提交历史整理成直线；
# rebase的目的是使得我们在查看历史提交的变化时更容易，因为分叉的提交需要三方对比。
# 遇到的问题总结：
# 一开始按照教程演示去操作，因为两个目录修改的不是同一文件，git pull 后直接合并了没有冲突，所以git rebase有效果。
# 如果git pull后提示有冲突后，先不管冲突的代码，因为修改后执行rebase还是变回有冲突的代码。先执行git add . 和 git commit -m 'xxx'。
# 在执行git rebase 终端提示：Resolve all conflicts manually, mark them as resolved with "git add/rm <conflicted_files>",
# then run "git rebase --continue”。这时再手动修改代码解决冲突，执行git add . 再执行 git rebase --continue 就有效果了。
# 这时直接git push 到远程仓库即可

# ----------------------------自定义 git -------------------------------
git add -f App.class  # 强制添加文件到暂存区，即便文件在 .gitignore 中指定
git check-ignore -v App.class  # 检查 .gitignore 中哪条规则忽略了指定的文件

git config --global alias.st status # 配置别名，配置后， st就可以代替 status
# 其他常见的别名
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.unstage 'reset HEAD'
git config --global alias.last 'log -1'  # 显示最后一次提交信息
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# 配置Git的时候，加上--global是针对当前用户起作用的，如果不加，那只针对当前的仓库起作用。
# 配置文件放哪了？每个仓库的Git配置文件都放在.git/config文件中：
cat .git/config
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
    ignorecase = true
    precomposeunicode = true
[remote "origin"]
    url = git@github.com:michaelliao/learngit.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
    remote = origin
    merge = refs/heads/master
[alias]
    last = log -1
# 别名就在[alias]后面，要删除别名，直接把对应的行删掉即可。
# 而当前用户的Git配置文件放在用户主目录下的一个隐藏文件.gitconfig中：
cat .gitconfig
[alias]
    co = checkout
    ci = commit
    br = branch
    st = status
[user]
    name = Your Name
    email = your@email.com
# 配置别名也可以直接修改这个文件，如果改错了，可以删掉文件重新通过命令配置。


# -----------------------------------搭建git服务器--------------------------------------------
apt-get install git
adduser git
# 收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。
# 先选定一个目录作为Git仓库，假定是/srv/sample.git，在/srv目录下输入命令：
git init --bare sample.git
# Git就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的Git仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的Git仓库通常都以.git结尾。然后，把owner改为git
chown -R git:git sample.git
# 禁用shell登录：
# 出于安全考虑，第二步创建的git用户不允许登录shell，这可以通过编辑/etc/passwd文件完成。找到类似下面的一行：
git:x:1001:1001:,,,:/home/git:/bin/bash
改为：
git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell
# 这样，git用户可以正常通过ssh使用git，但无法登录shell，因为我们为git用户指定的git-shell每次一登录就自动退出
# 现在，可以通过git clone命令克隆远程仓库了，在各自的电脑上运行
git clone git@server:/srv/sample.git
# 管理公钥
# 如果团队很小，把每个人的公钥收集起来放到服务器的/home/git/.ssh/authorized_keys文件里就是可行的。
# 如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。

# 管理权限
# 有很多不但视源代码如生命，而且视员工为窃贼的公司，会在版本控制系统里设置一套完善的权限控制，
# 每个人是否有读写权限会精确到每个分支甚至每个目录下。因为Git是为Linux源代码托管而开发的，
# 所以Git也继承了开源社区的精神，不支持权限控制。不过，因为Git支持钩子（hook），所以，
# 可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。
