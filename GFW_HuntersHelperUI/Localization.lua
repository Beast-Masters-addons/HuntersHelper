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
