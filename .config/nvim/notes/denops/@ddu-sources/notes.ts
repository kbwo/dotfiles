// ddu source for the notes under ~/notes: what to list comes from the Lua side
// (lua/notes/ddu.lua `items`), which owns the search and the pages.
//   params.mode "search": pages matching the input, one item each (set the source volatile);
//     action "reveal" shows the chosen page's card in the list, or with params.command opens it so
//   params.mode "titles": every page but params.except, by title; action "merge" merges into it
import type { ActionArguments, Actions, Item } from "jsr:@shougo/ddu-vim@~11.0.0/types";
import { ActionFlags } from "jsr:@shougo/ddu-vim@~11.0.0/types";
import { BaseSource, type GatherArguments } from "jsr:@shougo/ddu-vim@~11.0.0/source";
import type { ActionData } from "jsr:@shougo/ddu-kind-file@~1.0.0";

type Params = {
  mode: "search" | "titles";
  except: string;
};

export class Source extends BaseSource<Params, ActionData> {
  override kind = "file";

  override actions: Actions<Params> = {
    reveal: async ({ denops, items, actionParams }: ActionArguments<Params>) => {
      const action = items[0]?.action as ActionData | undefined;
      if (action?.path) {
        const command = (actionParams as { command?: string } | undefined)?.command ?? "";
        await denops.call(
          "luaeval",
          "require('notes.ddu').reveal_picked(_A[1], _A[2], _A[3])",
          [action.path, action.lineNr ?? 0, command],
        );
      }
      return ActionFlags.None;
    },
    merge: async ({ denops, items }: ActionArguments<Params>) => {
      const path = (items[0]?.action as ActionData | undefined)?.path;
      if (path) {
        await denops.call("luaeval", "require('notes.ddu').merge_picked(_A)", path);
      }
      return ActionFlags.None;
    },
  };

  override gather(
    { denops, sourceParams, input }: GatherArguments<Params>,
  ): ReadableStream<Item<ActionData>[]> {
    return new ReadableStream({
      async start(controller) {
        const items = await denops.call(
          "luaeval",
          "require('notes.ddu').items(_A)",
          { mode: sourceParams.mode, input, except: sourceParams.except },
        ) as Item<ActionData>[];
        controller.enqueue(items);
        controller.close();
      },
    });
  }

  override params(): Params {
    return { mode: "search", except: "" };
  }
}
