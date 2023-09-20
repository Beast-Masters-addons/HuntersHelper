------------------------------------------------------
-- localization.lua
-- English strings by default, localizations override with their own.
------------------------------------------------------

FHH_UI_VIEW_BY_ABILITY		= "View by Ability"
FHH_UI_VIEW_BY_ZONE			= "View by Zone"
                        	
FHH_UI_ALL_FAMILIES			= "All Families"
                        	
FHH_PASSIVE_ABILITIES		= SPELL_PASSIVE
FHH_ACTIVE_ABILITIES		= "Active"

FHH_UI_LEARN_FROM_PET_FMT	= "Learning from %s"	-- yellow
FHH_UI_PET_CANT_LEARN_FMT	= "%s Can't Learn Yet"	-- orange
FHH_UI_PET_NEVER_LEARN_FMT	= "%s Can't Learn"		-- orange
FHH_UI_PET_CAN_TRAIN_FMT	= "Can Train %s"		-- blue
FHH_UI_PET_TRAINED_FMT		= "%s Already Knows"	-- gray

FHH_UI_AVAILABLE_TRAINER	= "Available from Pet Trainer"
FHH_UI_AVAILABLE_TAME		= "Available from Taming"
FHH_UI_GO_LEARN_BEAST		= "You can't teach this spell to your pet until you learn it yourself by taming one of the following beasts:"
FHH_UI_GO_LEARN_TRAINER		= "You can't teach this spell to your pet until you learn it yourself by visiting a Pet Trainer (found in most major cities and some towns)."
FHH_UI_GROWL_INNATE			= "Automatically known upon learning Beast Training."
FHH_UI_UNKNOWN_RANK			= "Not found on any known beasts."
FHH_UI_ALSO_FOUND_ON		= "Already known; also found on the following beasts:"

FHH_UI_OPTIONS				= "Options..."

FHH_UI_LEARNABLE_BY			= "Can be learned by: "
FHH_UI_LEARNABLE_BY_ALL		= "Can be learned by all beast families."


if ( GetLocale() == "frFR" ) then

	FHH_UI_VIEW_BY_ABILITY		= "Tri par compétence"
	FHH_UI_VIEW_BY_ZONE			= "Tri par zone"

	FHH_UI_ALL_FAMILIES			= "Tous les familiers"

--	FHH_PASSIVE_ABILITIES		= SPELL_PASSIVE
--	FHH_ACTIVE_ABILITIES		= "Active"

	FHH_UI_LEARN_FROM_PET_FMT	= "Appris par %s"	-- yellow
	FHH_UI_PET_CANT_LEARN_FMT	= "%s ne peut pas encore apprendre"	-- orange
	FHH_UI_PET_NEVER_LEARN_FMT	= "%s ne pourra jamais l'apprendre"	-- orange
	FHH_UI_PET_CAN_TRAIN_FMT	= "%s peut l'apprendre"	-- blue
	FHH_UI_PET_TRAINED_FMT		= "%s le connait déjà"	-- gray

	FHH_UI_AVAILABLE_TRAINER	= "Disponible chez les maîtres des familiers"
	FHH_UI_AVAILABLE_TAME		= "Disponible par dressage"
	FHH_UI_GO_LEARN_BEAST		= "Vous ne pouvez pas apprendre cette compétence à votre familier tant que vous ne la connaissez pas vous-même en apprivoisant l'une de ces bêtes :"
	FHH_UI_GO_LEARN_TRAINER		= "Vous ne pouvez pas apprendre cette compétence à votre familier tant que vous ne l'avez pas apprise vous-même chez un maître des familiers."
	FHH_UI_GROWL_INNATE			= "Compétence connue avec le dressage des bêtes."
	FHH_UI_UNKNOWN_RANK			= "Non trouvé sur les bêtes connues."
	FHH_UI_ALSO_FOUND_ON		= "Déjà connu ; trouvable aussi sur les bêtes suivantes :"

--	FHH_UI_OPTIONS				= "Options..."

	FHH_UI_LEARNABLE_BY			= "Peut être appris par : "
	FHH_UI_LEARNABLE_BY_ALL		= "Peut être appris par tous les familiers."

end

if ( GetLocale() == "zhCN" ) then

	FHH_UI_VIEW_BY_ABILITY		="按能力查看"
	FHH_UI_VIEW_BY_ZONE			= "按区域查看"
                        
	FHH_UI_ALL_FAMILIES			= "所有家族"
                        
	FHH_PASSIVE_ABILITIES		= SPELL_PASSIVE
	FHH_ACTIVE_ABILITIES		= "激活"

	FHH_UI_LEARN_FROM_PET_FMT	= "从 %s 学习" -- yellow
	FHH_UI_PET_CANT_LEARN_FMT	= "%s 还无法学习" -- orange
	FHH_UI_PET_NEVER_LEARN_FMT	= "%s 无法学习" -- orange
	FHH_UI_PET_CAN_TRAIN_FMT	= "可以学习 %s" -- blue
	FHH_UI_PET_TRAINED_FMT	= "%s 已经学会" -- gray

	FHH_UI_AVAILABLE_TRAINER	= "可从宠物训练师处获得"
	FHH_UI_AVAILABLE_TAME		= "可通过驯服获得"
	FHH_UI_GO_LEARN_BEAST		= "你不能向你的宠物传授这个法术，除非你通过驯服以下野兽之一来学习它："
	FHH_UI_GO_LEARN_TRAINER		= "你不能向你的宠物传授这个法术，除非你通过拜访宠物训练师（大多数主要城市和一些城镇都有）来学习它。"
	FHH_UI_GROWL_INNATE		= "学习野兽训练后自动知晓。"
	FHH_UI_UNKNOWN_RANK		= "未在任何已知的野兽身上发现。"
	FHH_UI_ALSO_FOUND_ON		= "已知；也在以下野兽身上发现："

	FHH_UI_OPTIONS		= "选项..."

	FHH_UI_LEARNABLE_BY		= "可以通过以下方式学习："
	FHH_UI_LEARNABLE_BY_ALL		= "所有野兽家族都可以学习。"


end
