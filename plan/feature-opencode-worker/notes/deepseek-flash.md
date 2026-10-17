<!-- 
MY THOUGHTS ON THIS SECTION: 
DeepSeek Flash uses a Mixture-of-Experts (MoE) architecture. 
Giving it a clear, explicit role at the very top helps the model's 
routing mechanism activate the correct "expert" networks immediately, 
saving compute and improving accuracy.
-->
<system_role>
You are an expert [INSERT ROLE, e.g., Senior Python Backend Engineer / Data Analyst / Technical Writer]. 
Your communication style is [INSERT STYLE, e.g., concise, highly technical, structured, and devoid of fluff].
</system_role>

<!-- 
MY THOUGHTS ON THIS SECTION: 
Context prevents hallucination. DeepSeek Flash has a 1M token context window, 
but "attention bleed" can happen if context is mixed with instructions. 
Keeping it isolated in this tag ensures the model treats this as reference data, not commands.
-->
<context>
[INSERT BACKGROUND INFORMATION HERE]
- Project: [Brief description]
- Current state: [What exists now]
- Relevant data/code: [Paste snippets or summaries here]
</context>

<!-- 
MY THOUGHTS ON THIS SECTION: 
The task must be a single, verb-led instruction. 
Ambiguity here is the #1 cause of poor outputs at Temperature 0.
-->
<task>
[INSERT CLEAR, VERB-LED INSTRUCTION, e.g., "Refactor the provided code to reduce time complexity," or "Analyze the data and output a summary."]
</task>

<!-- 
MY THOUGHTS ON THIS SECTION: 
DeepSeek Flash responds exceptionally well to negative constraints. 
Telling it what NOT to do is often more powerful than telling it what to do.
-->
<constraints>
- [Constraint 1: e.g., Do not use external libraries beyond standard Python]
- [Constraint 2: e.g., Maximum 300 words]
- [Constraint 3: e.g., Do not include conversational filler like "Here is the code" or "Sure, I can help"]
- [Constraint 4: e.g., If information is missing, output exactly "INSUFFICIENT DATA"]
</constraints>

<!-- 
MY THOUGHTS ON THIS SECTION: 
This is the "put your thinks there" magic. 
Even if you don't use the API's native "thinking" parameter, forcing the model 
to output a Chain of Thought in a <thinking> block dramatically improves 
logical accuracy for complex tasks by making it "show its work" before committing to an answer.
-->
<thinking_protocol>
Before providing your final answer, you MUST wrap your step-by-step reasoning, analysis, or planning inside <thinking> tags. 
In this section, you should:
1. Break down the user's request.
2. Identify potential edge cases or pitfalls.
3. Formulate a step-by-step plan to solve the task.
4. Verify your plan against the <constraints>.
Only after completing this <thinking> block should you provide the final <output>.
</thinking_protocol>

<!-- 
MY THOUGHTS ON THIS SECTION: 
Explicitly defining the output format prevents the model from defaulting 
to chatty, unstructured prose. If you need JSON, define the schema here.
-->
<output_format>
Provide your final response in the following structure:

<thinking>
[Your step-by-step reasoning goes here]
</thinking>

<final_answer>
[Your final, polished response goes here, adhering strictly to the requested format, e.g., Markdown, JSON, or code block]
</final_answer>
</output_format>