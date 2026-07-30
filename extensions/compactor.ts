import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "compact",
    label: "Compact Context",
    description: "Summarizes the older parts of the conversation to free up context window. Use this after completing an iterative task or when the history feels 'crowded'.",
    parameters: Type.Object({
      instructions: Type.Optional(Type.String({ 
        description: "Focus instructions for the summary (e.g. 'Focus on the final 3D geometry of the feet')" 
      })),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      ctx.compact({
        customInstructions: params.instructions,
        onComplete: () => {
          ctx.ui.notify("Agent-initiated compaction complete.", "info");
        }
      });
      
      return {
        content: [{ 
          type: "text", 
          text: "I have initiated a context compaction. The summary will be applied to the next turn, effectively 'refreshing' my focus." 
        }],
      };
    },
  });
}
