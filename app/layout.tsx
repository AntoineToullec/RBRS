import './global.css'
import React from 'react'
import type { Metadata } from 'next'
import { Analytics } from '@vercel/analytics/react'
import { SpeedInsights } from '@vercel/speed-insights/next'
import { baseUrl } from './sitemap'

export const metadata: Metadata = {
    metadataBase: new URL(baseUrl),
    title: {
        default: 'RBRS Manager',
        template: '%s | RBRS Manager',
    },
    description: 'This is RBRS Manager.',
    openGraph: {
        title: 'RBRS Manager',
        description: 'This is RBRS Manager.',
        url: baseUrl,
        siteName: 'RBRS Manager',
        locale: 'en_US',
        type: 'website',
    },
    robots: {
        index: true,
        follow: true,
        googleBot: {
            index: true,
            follow: true,
            'max-video-preview': -1,
            'max-image-preview': 'large',
            'max-snippet': -1,
        },
    },
}

const cx = (...classes: string[]) => classes.filter(Boolean).join(' ')

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html
            lang="en"
        >
            <head>
                <link rel="icon" href="/favicon.png" sizes='any' />
            </head>
            <body className={cx('antialiased text-black bg-white dark:text-white dark:bg-black md:mx-auto')}>
                <main>
                    {children}
                    <Analytics />
                    <SpeedInsights />
                </main>
            </body>
        </html>
    )
}
