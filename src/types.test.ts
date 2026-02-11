import { describe, expect, it } from "vitest";
import { init } from "./index";
import type { Comment, CommentPage, ElementAnchor } from "./types";

describe("types", () => {
  it("Comment satisfies the interface", () => {
    const comment: Comment = {
      id: "test-id",
      anchor: {
        selector: "#btn",
        boundingRect: new DOMRect(0, 0, 100, 32),
        tagName: "BUTTON",
        htmlSnapshot: "<button>click</button>",
      },
      text: "test comment",
      status: "active",
      createdAt: "2024-01-01T00:00:00Z",
      updatedAt: "2024-01-01T00:00:00Z",
    };
    expect(comment.id).toBe("test-id");
    expect(comment.status).toBe("active");
  });

  it("ElementAnchor accepts optional fields", () => {
    const anchor: ElementAnchor = {
      selector: "[data-testid='login']",
      componentName: "LoginForm",
      filePath: "src/LoginForm.tsx:24",
      boundingRect: new DOMRect(0, 0, 80, 32),
      textContent: "Login",
      tagName: "BUTTON",
      htmlSnapshot: "<button>Login</button>",
    };
    expect(anchor.componentName).toBe("LoginForm");
  });

  it("CommentPage holds comments array", () => {
    const page: CommentPage = {
      version: 1,
      pathname: "/",
      updatedAt: "2024-01-01T00:00:00Z",
      comments: [],
    };
    expect(page.comments).toHaveLength(0);
  });
});

describe("init", () => {
  it("is exported as a function", () => {
    expect(typeof init).toBe("function");
  });
});
