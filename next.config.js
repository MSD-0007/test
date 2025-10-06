/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'export',
  images: {
    unoptimized: true,
    domains: ['www.wallpaperflare.com', 'firebasestorage.googleapis.com'],
  },
}

module.exports = nextConfig 