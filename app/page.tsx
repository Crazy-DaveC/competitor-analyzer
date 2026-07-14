"use client";

import { useState } from "react";

export default function CompetitorAnalysisPage() {
  const [message, setMessage] = useState("");
  const [audiences, setAudiences] = useState<string[]>([""]);
  const [competitors, setCompetitors] = useState<string[]>([""]);
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);

  const addAudience = () => {
    setAudiences([...audiences, ""]);
  };

  const updateAudience = (index: number, value: string) => {
    const newAudiences = [...audiences];
    newAudiences[index] = value;
    setAudiences(newAudiences);
  };

  const removeAudience = (index: number) => {
    if (audiences.length > 1) {
      setAudiences(audiences.filter((_, i) => i !== index));
    }
  };

  const addCompetitor = () => {
    setCompetitors([...competitors, ""]);
  };

  const updateCompetitor = (index: number, value: string) => {
    const newCompetitors = [...competitors];
    newCompetitors[index] = value;
    setCompetitors(newCompetitors);
  };

  const removeCompetitor = (index: number) => {
    if (competitors.length > 1) {
      setCompetitors(competitors.filter((_, i) => i !== index));
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadedFile(file);
      const reader = new FileReader();
      reader.onload = (event) => {
        setMessage(event.target?.result as string);
      };
      reader.readAsText(file);
    }
  };

  const analyzeMessage = async () => {
    setLoading(true);
    setResult(null);

    try {
      const response = await fetch("/api/competitor-analysis", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message,
          audiences: audiences.filter((a) => a.trim() !== ""),
          competitors: competitors.filter((c) => c.trim() !== ""),
        }),
      });

      const data = await response.json();
      
      if (!response.ok) {
        console.error("API Error:", data);
        alert(`Error: ${data.error || 'Failed to analyze message'}\n${data.details || ''}`);
        setLoading(false);
        return;
      }
      
      setResult(data);
    } catch (error) {
      console.error("Error analyzing message:", error);
      alert("Failed to analyze message. Please check the console for details.");
    }

    setLoading(false);
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        backgroundColor: "#000",
        color: "#fff",
        fontFamily: "Arial, sans-serif",
        padding: 32,
      }}
    >
      {/* Header */}
      <div style={{ marginBottom: 40 }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ fontWeight: 700, fontSize: 24, color: "#0f62fe", letterSpacing: 2 }}>IBM</div>
            <h1 style={{ margin: 0, fontSize: 32 }}>Competitor Response Analyzer</h1>
          </div>
          <a
            href="/api/auth/logout"
            style={{
              padding: "8px 16px",
              background: "#333",
              color: "#aaa",
              border: "1px solid #444",
              borderRadius: 4,
              textDecoration: "none",
              fontSize: 14,
            }}
          >
            Sign Out
          </a>
        </div>
        <p style={{ color: "#aaa", margin: 0, fontSize: 16 }}>
          Test how competitors might react to your marketing messages
        </p>
        <div style={{ marginTop: 16, padding: "16px 20px", background: "#111", border: "1px solid #333", borderRadius: 6, maxWidth: 800 }}>
          <p style={{ margin: "0 0 12px 0", color: "#ccc", fontSize: 14, lineHeight: 1.7 }}>
            The competitor response analyzer is meant to be a tool that allows, for those writing copy, to understand how competitors may react to our announcements, messages, ads, etc. It allows writers to anticipate and adjust copy in order further clarify and differentiate IBM&apos;s message.
          </p>
          <ol style={{ margin: 0, paddingLeft: 20, color: "#aaa", fontSize: 14, lineHeight: 1.9 }}>
            <li>Enter audiences representing the target audience for the message.</li>
            <li>Paste or upload message (text).</li>
            <li>Enter competitors most aligned to the message concept.</li>
            <li>Click &ldquo;Analyze Competitor Responses&rdquo; &mdash; scroll down for analysis</li>
          </ol>
        </div>
      </div>

      {/* Input Section */}
      <div style={{ maxWidth: 1200 }}>
        <div style={{ marginBottom: 40 }}>
          <h2 style={{ fontSize: 24, marginBottom: 16 }}>1. Define Your Target Audiences</h2>
          {audiences.map((audience, index) => (
            <div key={index} style={{ display: "flex", gap: 8, marginBottom: 12 }}>
              <input
                placeholder={`Audience ${index + 1} (e.g., CIOs, Marketing Directors)`}
                value={audience}
                onChange={(e) => updateAudience(index, e.target.value)}
                style={{
                  flex: 1,
                  padding: 12,
                  background: "#111",
                  color: "#fff",
                  border: "1px solid #333",
                  borderRadius: 4,
                }}
              />
              {audiences.length > 1 && (
                <button
                  onClick={() => removeAudience(index)}
                  style={{
                    padding: "12px 16px",
                    background: "#333",
                    color: "#fff",
                    border: "none",
                    borderRadius: 4,
                    cursor: "pointer",
                  }}
                >
                  Remove
                </button>
              )}
            </div>
          ))}
          <button
            onClick={addAudience}
            style={{
              padding: "10px 16px",
              background: "#0f62fe",
              color: "#fff",
              border: "none",
              borderRadius: 4,
              cursor: "pointer",
              marginTop: 8,
            }}
          >
            + Add Audience
          </button>
        </div>

        <div style={{ marginBottom: 40 }}>
          <h2 style={{ fontSize: 24, marginBottom: 16 }}>2. Enter or Upload Your Message</h2>
          <textarea
            placeholder="Paste your marketing message here..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            style={{
              width: "100%",
              minHeight: 200,
              padding: 12,
              background: "#111",
              color: "#fff",
              border: "1px solid #333",
              borderRadius: 4,
              fontFamily: "monospace",
              fontSize: 14,
              resize: "vertical",
            }}
          />
          <div style={{ marginTop: 12 }}>
            <label
              style={{
                padding: "10px 16px",
                background: "#333",
                color: "#fff",
                borderRadius: 4,
                cursor: "pointer",
                display: "inline-block",
              }}
            >
              📎 Upload File
              <input
                type="file"
                accept=".txt,.md,.doc,.docx"
                onChange={handleFileUpload}
                style={{ display: "none" }}
              />
            </label>
            {uploadedFile && (
              <span style={{ marginLeft: 12, color: "#aaa" }}>
                Uploaded: {uploadedFile.name}
              </span>
            )}
          </div>
        </div>

        <div style={{ marginBottom: 40 }}>
          <h2 style={{ fontSize: 24, marginBottom: 16 }}>3. Name Your Competitors</h2>
          {competitors.map((competitor, index) => (
            <div key={index} style={{ display: "flex", gap: 8, marginBottom: 12 }}>
              <input
                placeholder={`Competitor ${index + 1} (e.g., Microsoft, Salesforce)`}
                value={competitor}
                onChange={(e) => updateCompetitor(index, e.target.value)}
                style={{
                  flex: 1,
                  padding: 12,
                  background: "#111",
                  color: "#fff",
                  border: "1px solid #333",
                  borderRadius: 4,
                }}
              />
              {competitors.length > 1 && (
                <button
                  onClick={() => removeCompetitor(index)}
                  style={{
                    padding: "12px 16px",
                    background: "#333",
                    color: "#fff",
                    border: "none",
                    borderRadius: 4,
                    cursor: "pointer",
                  }}
                >
                  Remove
                </button>
              )}
            </div>
          ))}
          <button
            onClick={addCompetitor}
            style={{
              padding: "10px 16px",
              background: "#0f62fe",
              color: "#fff",
              border: "none",
              borderRadius: 4,
              cursor: "pointer",
              marginTop: 8,
            }}
          >
            + Add Competitor
          </button>
        </div>

        <button
          onClick={analyzeMessage}
          disabled={loading || !message.trim() || audiences.filter(a => a.trim()).length === 0 || competitors.filter(c => c.trim()).length === 0}
          style={{
            padding: "16px 32px",
            background: loading ? "#666" : "#fff",
            color: "#000",
            border: "none",
            borderRadius: 4,
            cursor: loading ? "not-allowed" : "pointer",
            fontSize: 16,
            fontWeight: 600,
          }}
        >
          {loading ? "Analyzing..." : "Analyze Competitor Responses"}
        </button>
      </div>

      {/* Results Section */}
      {result && (
        <div style={{ marginTop: 60, maxWidth: 1200 }}>
          <h2 style={{ fontSize: 28, marginBottom: 24, borderBottom: "2px solid #333", paddingBottom: 12 }}>
            Analysis Results
          </h2>

          {/* Overall Assessment */}
          <div style={{ background: "#111", padding: 24, borderRadius: 8, marginBottom: 24, border: "1px solid #333" }}>
            <h3 style={{ fontSize: 20, marginBottom: 12, color: "#0f62fe" }}>Overall Assessment</h3>
            <p style={{ fontSize: 16, lineHeight: 1.6 }}>{result.overallAssessment}</p>
          </div>

          {/* Competitor Responses */}
          <div style={{ marginBottom: 24 }}>
            <h3 style={{ fontSize: 22, marginBottom: 16 }}>Predicted Competitor Responses</h3>
            {result.competitorResponses?.map((response: any, index: number) => (
              <div
                key={index}
                style={{
                  background: "#111",
                  padding: 20,
                  borderRadius: 8,
                  marginBottom: 16,
                  border: "1px solid #333",
                }}
              >
                <h4 style={{ fontSize: 18, marginBottom: 12, color: "#fff" }}>
                  {response.competitor}
                </h4>
                <div style={{ marginBottom: 12 }}>
                  <strong style={{ color: "#0f62fe" }}>Likely Response Strategy:</strong>
                  <p style={{ marginTop: 4, lineHeight: 1.6 }}>{response.strategy}</p>
                </div>
                <div style={{ marginBottom: 12 }}>
                  <strong style={{ color: "#0f62fe" }}>Counter-Messaging:</strong>
                  <p style={{ marginTop: 4, lineHeight: 1.6, fontStyle: "italic", color: "#ddd" }}>
                    "{response.counterMessage}"
                  </p>
                </div>
                <div>
                  <strong style={{ color: "#0f62fe" }}>Threat Level:</strong>
                  <span
                    style={{
                      marginLeft: 8,
                      padding: "4px 12px",
                      background: response.threatLevel === "High" ? "#da1e28" : response.threatLevel === "Medium" ? "#f1c21b" : "#24a148",
                      color: "#000",
                      borderRadius: 4,
                      fontSize: 14,
                      fontWeight: 600,
                    }}
                  >
                    {response.threatLevel}
                  </span>
                </div>
              </div>
            ))}
          </div>

          {/* Audience Reactions */}
          <div style={{ marginBottom: 24 }}>
            <h3 style={{ fontSize: 22, marginBottom: 16 }}>Audience Reactions</h3>
            {result.audienceReactions?.map((reaction: any, index: number) => (
              <div
                key={index}
                style={{
                  background: "#111",
                  padding: 20,
                  borderRadius: 8,
                  marginBottom: 16,
                  border: "1px solid #333",
                }}
              >
                <h4 style={{ fontSize: 18, marginBottom: 12, color: "#fff" }}>
                  {reaction.audience}
                </h4>
                <div style={{ marginBottom: 8 }}>
                  <strong style={{ color: "#0f62fe" }}>Initial Reaction:</strong>
                  <p style={{ marginTop: 4 }}>{reaction.initialReaction}</p>
                </div>
                <div>
                  <strong style={{ color: "#0f62fe" }}>Key Concerns:</strong>
                  <ul style={{ marginTop: 4, paddingLeft: 20 }}>
                    {reaction.concerns?.map((concern: string, i: number) => (
                      <li key={i} style={{ marginBottom: 4 }}>{concern}</li>
                    ))}
                  </ul>
                </div>
              </div>
            ))}
          </div>

          {/* Recommendations */}
          <div style={{ background: "#0f62fe", padding: 24, borderRadius: 8, marginBottom: 24 }}>
            <h3 style={{ fontSize: 22, marginBottom: 16, color: "#fff" }}>Strategic Recommendations</h3>
            <ul style={{ paddingLeft: 20, lineHeight: 1.8 }}>
              {result.recommendations?.map((rec: string, index: number) => (
                <li key={index} style={{ marginBottom: 8 }}>{rec}</li>
              ))}
            </ul>
          </div>

          {/* Vulnerabilities */}
          <div style={{ background: "#111", padding: 24, borderRadius: 8, border: "1px solid #da1e28", marginBottom: 24 }}>
            <h3 style={{ fontSize: 22, marginBottom: 16, color: "#da1e28" }}>Potential Vulnerabilities</h3>
            <ul style={{ paddingLeft: 20, lineHeight: 1.8 }}>
              {result.vulnerabilities?.map((vuln: string, index: number) => (
                <li key={index} style={{ marginBottom: 8 }}>{vuln}</li>
              ))}
            </ul>
          </div>

          {/* Sources */}
          {result.sources && result.sources.length > 0 && (
            <div style={{ background: "#111", padding: 24, borderRadius: 8, border: "1px solid #333" }}>
              <h3 style={{ fontSize: 20, marginBottom: 12, color: "#aaa" }}>Sources Referenced</h3>
              <ul style={{ paddingLeft: 20, lineHeight: 1.8, margin: 0 }}>
                {result.sources.slice(0, 5).map((source: string, index: number) => (
                  <li key={index} style={{ marginBottom: 6, color: "#ccc", fontSize: 14 }}>{source}</li>
                ))}
              </ul>
              {result.sources.length > 5 && (
                <p style={{ marginTop: 8, color: "#666", fontSize: 13 }}>
                  + {result.sources.length - 5} more source{result.sources.length - 5 > 1 ? "s" : ""}
                </p>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// Made with Bob
