# The Design Loop: Closing the Gap Between AI and 3D Reality with OpenSCAD

*July 30, 2026*

---

At some point, 3D printing stops being about downloading other people's STLs. You look at a broken part on a piece of equipment—a bike repair stand, for instance—and you think: *I can make this.* But designing a replacement isn't just about modeling; it's about verifying that what you modeled is actually shaped like the thing you're replacing.

This is the story of how we built an OpenSCAD skill for Pi that closes that loop: a multi-modal agent that *looks at the real thing*, *generates 3D code*, *renders six orthographic views*, *reads those views back as images*, and *corrects its own mistakes*—all in a tight loop, without a human guiding each step.

---

## The Skill: An Agentic Negative Feedback Loop

The OpenSCAD skill is built around a simple but powerful idea: the agent's output becomes its own input. Here's the loop:

```
Write .scad → Render STL → Generate 6-view screenshots
    → Read screenshots → Analyze geometry → Fix issues → Repeat
```

Each screenshot is an orthographic projection from one camera angle: front, back, top, bottom, left, right. The agent uses the `read` tool—which converts PNGs into image attachments—to literally *see* what it just made.

This is the **negative feedback loop**. The agent "looks" at its work, compares it to the intended design, identifies deviations, and corrects them. It's the same loop a human designer uses when staring at a CAD viewport, just executed by code.

---

## Case Study 1: The Bike Repair Stand Grip Cover

The task was to design a replacement grip cover for a bike repair stand. The prompt described it precisely:

> "It has an L cross-section, with the part being covered having 35mm length on both legs of the L. The corners and ends of the L are rounded. The L is extruded 25mm deep. Surround that part with 2.5mm on all sides but one so that it can be slid on."

![The broken grip covers on a bike repair stand](images/grip_cover.jpg)

### Iteration 1: The Triangle Error
The agent's first attempt used a `hull()` of three circles. It rendered the views and looked at the top-down screenshot. What it saw was not an L—it was a rounded triangle. The agent recognized the error *immediately* from the screenshot:

> "The `hull()` of three circles creates a triangle, not an L-shape. To create an L-shape, I need to hull two separate rectangles."

### Iteration 2: The Centering and Corners
The second attempt produced an L, but the agent spotted a centering bug (the wall thickness wasn't uniform) and a sharp internal corner that didn't match the reference photo. 

Instead of manual fixes, the agent switched to an elegant **offset strategy**:
1. Define the base L-shape.
2. Use `offset(r=ROUNDING)` to round *every* corner (inside and out).
3. Use `offset(r=WALL)` to create a perfect outer shell.

![The final corrected L-profile from the top view](images/top.png)
*Above: The final refined geometry, showing uniform wall thickness and rounded corners.*

![Comparison of old blue cracked cover and new black 3D printed replacement](images/PXL_20260728_042400035.jpg)
*Above: The printed result (black) vs the original (blue). A perfect fit.*

![New black grip cover installed on the bike repair stand](images/PXL_20260728_210516691.jpg)
*Above: The final part installed and functioning on the stand.*

---

## Case Study 2: Generative Detail (The Minecraft Creeper)

Once the basic feedback loop was proven, we pushed it further. Could the agent handle generative, high-fidelity geometry?

The agent was asked to design a Minecraft Creeper, but with a twist: "Sub-pixel surface detail." It wrote an OpenSCAD script that used a deterministic pseudo-random function to generate thousands of small cubes, each slightly offset to create a "noisy" or "glitchy" pixelated texture.

![High-fidelity pixelated Creeper in OpenSCAD](images/Screenshot%202026-07-30%20193629.png)
*Above: The "High-Fidelity Pixelated Edition" Creeper. Every surface is composed of jittered voxels.*

This demonstrates that the agent can reason about complex algorithmic geometry, not just simple primitives. Using **Gemini 3 Flash preview**, the agent used loops and functions to distribute detail across the model while maintaining the recognizable silhouette.

Notably, when we re-ran this task using **Gemma 4 31B** after optimizing our "fail fast" loop and script error handling, the open-weight model produced a pixelated version that was vastly superior to its initial attempts.

![Gemma V2 success after optimization](images/gemma-v2-success.png)
*Above: The Gemma V2 result, proving that a robust feedback loop can bridge the performance gap between model scales.*

---

## Case Study 3: Organic Forms (The Wild Turkey)

Can code-based CAD handle organic shapes? The "Wild Turkey" model proved it could. By combining spheres, cylinders, and polyhedra with hull operations and parametric offsets, the agent sculpted a surprisingly expressive model.

![3D printed wild turkey in copper PLA](images/wild-turkey-print.jpg)
*Above: The Wild Turkey model, 3D printed in copper-color PLA. The faceted, "low-poly" look is a stylistic choice generated by the agent's use of hull operations on simplified primitives.*

---

## Takeaways

1. **Multi-modal agents close the loop.** The agent doesn't just generate code; it *inspects* the results. This catches errors (like the triangle-L) that a purely text-based model would never see.
2. **Thinking blocks are the debug trace.** Every geometric correction is backed by a visible reasoning chain in the agent's thought process.
3. **OpenSCAD is the perfect AI medium.** Because OpenSCAD is code, it is versionable, parametric, and easily manipulated by LLMs.
4. **The "Fail Fast" Loop is Key.** Unlike human designers, agents don't get tired of fixing one bug at a time. By optimizing scripts to fail on the first error and return a clean "context-optimized" trace, we allow the agent to iterate rapidly without becoming overwhelmed by a cascade of secondary failures.
5. **The loop is reusable.** Whether it's a structural bike part, a generative character model, or an organic sculpture, the process remains the same: **Design → Render → See → Fix.**

The prints are coming off the bed. And for the first time, the AI is looking at them as they grow.
