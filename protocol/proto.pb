
�
common.proto"0
ItemData
id (Rid
count (Rcount"~

WeaponData
uid (Ruid
weaponId (RweaponId
level (Rlevel
star (Rstar
quailty (Rquailty"�
BagData/
itemMap (2.BagData.ItemMapEntryRitemMap$
equipedIdList (RequipedIdList5
	weaponMap (2.BagData.WeaponMapEntryR	weaponMap*
maxCanEquipCount (RmaxCanEquipCountE
ItemMapEntry
key (Rkey
value (2	.ItemDataRvalue:8I
WeaponMapEntry
key (Rkey!
value (2.WeaponDataRvalue:8"�
MailData
msgid (Rmsgid
id (	Rid
state (Rstate

jsonparams (	R
jsonparams%
itemlist (2	.ItemDataRitemlist"4

DOUBLE_INT
key (Rkey
value (Rvalue"V
TaskData
taskid (Rtaskid
state (Rstate
	condcount (R	condcount"|
TaskUpdateData

updatetype (R
updatetype
taskid (Rtaskid
state (Rstate
	condcount (R	condcount"<
TaskFinishData
taskid (Rtaskid
cout (Rcout*&
Type

MOBILE 
HOME
WORKB�
NetMessagebproto3
�

task.protocommon.proto"4
C2STaskList%
tasklist (2	.TaskDataRtasklist"4
S2CTaskList%
tasklist (2	.TaskDataRtasklist"B
S2CTaskUpdate1
updateinfos (2.TaskUpdateDataRupdateinfos"6

C2STaskOpt
opt (Ropt
taskid (RtaskidB�
NetMessagebproto3
�

mail.protocommon.proto".
S2CUpdateMail
mail (2	.MailDataRmail"
C2SMailList"4
S2CMailList%
maillist (2	.MailDataRmaillist"$
C2SMailState
msgid (Rmsgid"
S2CMailState"%
C2SMailRecive
msgid (Rmsgid"%
S2CMailRecive
msgid (Rmsgid"%
C2SMailDelete
msgid (Rmsgid"%
S2CMailDelete
msgid (Rmsgid"
C2SMailRecives"(
S2CMailRecives
msgids (Rmsgids"
C2SMailDeletes"(
S2CMailDeletes
msgids (RmsgidsB�
NetMessagebproto3
_
center.proto"%
C2SExchangeGift
code (	Rcode"
S2CExchangeGiftB�
NetMessagebproto3
�

user.protocommon.proto""
S2CErrorCode
code (Rcode""
C2SLogin
openid (	Ropenid"J
S2CLogin
ok (Rok
time (Rtime
timezone (Rtimezone"�
S2CUserData
openid (	Ropenid
uid (Ruid
name (	Rname
level (Rlevel
exp (Rexp
	logintime (R	logintime
gem (Rgem
gold (Rgold
levelId	 (RlevelId"
C2SBag"&
S2CBag
data (2.BagDataRdata"
C2SEquip
uid (Ruid",
S2CEquip
ok (Rok
uid (Ruid"

C2SUnEquip
uid (Ruid".

S2CUnEquip
ok (Rok
uid (Ruid"$
C2SUpgradeWeapon
uid (Ruid":
S2CUpgradeWeapon
uid (Ruid
level (Rlevel":
C2SGacha
chestId (RchestId
count (Rcount"7
S2CGacha+

weaponlist (2.WeaponDataR
weaponlist")
C2SPurchasePack
packId (RpackId"O
S2CPurchasePack
packId (RpackId
gem (Rgem
gold (Rgold"7
C2SGM
id (Rid

jsonParams (	R
jsonParams"
S2CGM"

C2SAdAppId"

S2CAdAppId
id (Rid"	
C2SAdId"
S2CAdId
id (RidB�
NetMessagebproto3