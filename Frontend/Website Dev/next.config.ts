import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactCompiler: true,
  // This tells Next.js to ignore the fact that styled-jsx is "client-only"
  // by treating the whole package as a client-side asset
  transpilePackages: ['react-hot-toast', 'styled-jsx'],
};

export default nextConfig;