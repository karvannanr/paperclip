import { createContext, useContext, useMemo, type ReactNode } from "react";
import { useQuery } from "@tanstack/react-query";
import { buildSkillMentionHref } from "@stapler/shared";
import { instanceSkillsApi } from "../api/skills";
import { routinesApi } from "../api/routines";
import { queryKeys } from "../lib/queryKeys";
import { useCompany } from "./CompanyContext";

export interface SkillCommandOption {
  id: string;
  kind: "skill";
  skillId: string;
  key: string;
  name: string;
  slug: string;
  description: string | null;
  href: string;
  aliases: string[];
}

export interface RoutineCommandOption {
  id: string;
  kind: "routine";
  routineId: string;
  name: string;
  status: string;
  href: string;
  aliases: string[];
}

export type SlashCommandOption = SkillCommandOption | RoutineCommandOption;

interface EditorAutocompleteContextValue {
  slashCommands: SlashCommandOption[];
}

const EditorAutocompleteContext = createContext<EditorAutocompleteContextValue>({
  slashCommands: [],
});

export function EditorAutocompleteProvider({ children }: { children: ReactNode }) {
  const { selectedCompanyId } = useCompany();
  const { data: skills = [] } = useQuery({
    queryKey: queryKeys.instanceSkills.list,
    queryFn: () => instanceSkillsApi.list(),
  });
  const { data: routines = [] } = useQuery({
    queryKey: selectedCompanyId
      ? queryKeys.routines.list(selectedCompanyId)
      : ["routines", "__none__", "__all-projects__"],
    queryFn: () => routinesApi.list(selectedCompanyId!),
    enabled: Boolean(selectedCompanyId),
  });

  const value = useMemo<EditorAutocompleteContextValue>(() => ({
    slashCommands: [
      ...skills.map((skill) => ({
        id: `skill:${skill.id}`,
        kind: "skill" as const,
        skillId: skill.id,
        key: skill.key,
        name: skill.name,
        slug: skill.slug,
        description: skill.description ?? null,
        href: buildSkillMentionHref(skill.id, skill.slug),
        aliases: [skill.slug, skill.name, skill.key],
      })),
      ...routines.map((routine) => ({
        id: `routine:${routine.id}`,
        kind: "routine" as const,
        routineId: routine.id,
        name: routine.title,
        status: routine.status,
        href: `/routines/${routine.id}`,
        aliases: [routine.title],
      })),
    ],
  }), [skills, routines]);

  return (
    <EditorAutocompleteContext.Provider value={value}>
      {children}
    </EditorAutocompleteContext.Provider>
  );
}

export function useEditorAutocomplete() {
  return useContext(EditorAutocompleteContext);
}
